import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Product.dart';


Future<List<int>> getEncryptionKey({required bool useSecondKey}) async {
  final prefs = await SharedPreferences.getInstance();
  String? keyString = prefs.getString(useSecondKey ? 'encryption_key2' : 'encryption_key1');

  if (keyString != null) {
    return keyString.split(',').map(int.parse).toList();
  }

  return [];
}

Future<List<int>> createAndSaveEncryptionKey({required bool useSecondKey}) async {
  final newKey = Hive.generateSecureKey();
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(useSecondKey ? 'encryption_key2' : 'encryption_key1', newKey.join(','));

  return newKey;
}

Future<void> saveProduct(Product product, {required bool useSecondKey}) async {
  final encryptionKey = await getEncryptionKey(useSecondKey: useSecondKey);
  final encryptedBox = await Hive.openBox<Product>(
    'products',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  await encryptedBox.put(DateTime.now().toString(), product);
  await encryptedBox.compact();
  await encryptedBox.close();
}

Future<List<Product>> getProducts({required bool useSecondKey}) async {
  final encryptionKey = await getEncryptionKey(useSecondKey: useSecondKey);
  final encryptedBox = await Hive.openBox<Product>(
    'products',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  final products = <Product>[];
  for (var key in encryptedBox.keys) {
    final product = encryptedBox.get(key);
    if (product != null) {
      products.add(product);
    }
  }
  await encryptedBox.compact();
  await encryptedBox.close();

  return products;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lab11/FoodItem.dart';

import 'tests.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  FoodItem,
])

void main(){
  late List<MockFoodItem> mockFoodItems;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
  late FoodItem foodItem;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    mockFoodItems = [
      MockFoodItem(),
    ];
    foodItem = FoodItem(
      id: 'test-id',
      title: 'Test Food',
      subtitle: 'Delicious',
      price: '10',
      imageUrl: '',
      isPro: true,
      isHot: false,
    );

    when(mockFirestore.collection('foodItems')).thenReturn(mockCollection);
    when(mockCollection.doc('test-id')).thenReturn(mockDocument);
    when(mockCollection.doc()).thenReturn(mockDocument);
    when(mockDocument.set(any)).thenAnswer((_) async => {});
    when(mockDocument.delete()).thenAnswer((_) async => {});
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
    when(mockQueryDocumentSnapshot.data()).thenReturn(foodItem.toMap());
  });

  group('FoodItems test', (){

    test('fetch', ()async{

      when(mockFoodItems[0].id).thenReturn('test-id');
      when(mockFoodItems[0].imageUrl).thenReturn('');
      when(mockFoodItems[0].title).thenReturn('test');
      when(mockFoodItems[0].subtitle).thenReturn('test');
      when(mockFoodItems[0].price).thenReturn('10');
      when(mockFoodItems[0].isPro).thenReturn(true);
      when(mockFoodItems[0].isHot).thenReturn(false);

      expect(mockFoodItems[0].id, equals('test-id'));
      expect(mockFoodItems[0].imageUrl, equals(''));
      expect(mockFoodItems[0].title, equals('test'));
      expect(mockFoodItems[0].subtitle, equals('test'));
      expect(mockFoodItems[0].price, equals('10'));
      expect(mockFoodItems[0].isPro, equals(true));
      expect(mockFoodItems[0].isHot, equals(false));

    });

    test('add_to_firebase', ()async{

      Future<void> addFoodItem(FoodItem foodItem) async {
        final docRef = mockFirestore.collection('foodItems').doc();
        await docRef.set(foodItem.toMap());
      }

      await addFoodItem(foodItem);

      final snapshot = await mockFirestore.collection('foodItems').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs[0].data(), equals(foodItem.toMap()));

    });

    test('delete_from_firebase', () async {
      Future<void> deleteFoodItem(String id) async {
        final docRef = mockFirestore.collection('foodItems').doc(id);
        await docRef.delete();
      }

      await deleteFoodItem('test-id');

      verify(mockDocument.delete()).called(1);
    });

  });
}
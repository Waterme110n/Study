import 'package:flutter_bloc/flutter_bloc.dart';


abstract class FoodEvent {}

class LoadFoodEvent extends FoodEvent {}

abstract class FoodState {}

class FoodInitial extends FoodState {}

class FoodLoaded extends FoodState {
  final List<Food> foodItems;

  FoodLoaded(this.foodItems);
}


class Food {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final bool isPro;
  final bool isHot;

  Food({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isPro,
    required this.isHot,
  });
}


class FoodBloc extends Bloc<FoodEvent, FoodState> {
  FoodBloc() : super(FoodInitial()) {
    on<LoadFoodEvent>((event, emit) {
      emit(FoodLoaded([
        Food(
          imageUrl: 'https://i.pinimg.com/736x/5e/a5/6f/5ea56f212bfdd2b70b31a9d3e95d6258.jpg',
          title: 'Pancakes',
          subtitle: 'pancake • banana',
          price: '\$1.99',
          isPro: true,
          isHot: true,
        ),
        Food(
          imageUrl: 'https://i.pinimg.com/736x/22/a0/f1/22a0f105bbadf3edbc5c158ba0d61f2b.jpg',
          title: 'Cookies',
          subtitle: 'cookie • strawberry',
          price: '\$3.49',
          isPro: false,
          isHot: false,
        ),
        Food(
          imageUrl:
          'https://i.pinimg.com/736x/8b/36/9f/8b369fefca44952ef36cc09f830c00e7.jpg',
          title: 'Burga',
          subtitle: 'burger • cheese',
          price: '\$5.99',
          isPro: false,
          isHot: true,
        ),
        Food(
          imageUrl:
          'https://i.pinimg.com/736x/87/7a/b9/877ab9df6ec6fb47851ef803d72550d7.jpg',
          title: 'Potato in Mundir',
          subtitle: 'Potato • Meet',
          price: '\$7.49',
          isPro: true,
          isHot: false,
        ),
      ]));
    });

    add(LoadFoodEvent());
  }
}
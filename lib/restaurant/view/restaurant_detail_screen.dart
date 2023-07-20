import 'package:delivery_app/common/layout/default_layout.dart';
import 'package:delivery_app/product/component/product_card.dart';
import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:flutter/widgets.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '불타는 떡볶이',
      child: Column(
        children: [
          RestaurantCard(
            image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
            name: '불타는 떡볶이',
            tags: const ['떡볶이', '맛있음', '치즈'],
            ratingsCount: 100,
            deliveryTime: 30,
            deliveryFee: 3000,
            ratings: 4.9,
            isDetail: true,
            detail: '맛있는 떡볶이',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: ProductCard(),
          )
        ],
      ),
    );
  }
}

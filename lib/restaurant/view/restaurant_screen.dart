import 'package:delivery_app/common/component/pagination_list_view.dart';
import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:delivery_app/restaurant/provider/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView(
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context
                .goNamed('restaurantDetail', pathParameters: {'rid': model.id});
          },
          child: RestaurantCard.fromModel(
            model: model,
          ),
        );
      },
      provider: restaurantProvider,
    );
  }
}

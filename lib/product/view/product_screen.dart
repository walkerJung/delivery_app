import 'package:delivery_app/common/component/pagination_list_view.dart';
import 'package:delivery_app/product/component/product_card.dart';
import 'package:delivery_app/product/model/product_model.dart';
import 'package:delivery_app/product/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      itemBuilder: <ProductModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context
                .goNamed('restaurantDetail', pathParameters: {'rid': model.id});
          },
          child: ProductCard.fromProductModel(model: model),
        );
      },
      provider: productProvider,
    );
  }
}

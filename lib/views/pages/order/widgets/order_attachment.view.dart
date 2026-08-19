import 'package:flutter/material.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/custom_grid_view.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderAttachmentView extends StatelessWidget {
  const OrderAttachmentView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.order.attachments == null || vm.order.attachments!.isEmpty) {
      return 0.heightBox;
    }

    //el título y el margen los pone la tarjeta que lo contiene
    return CustomGridView(
      dataSet: vm.order.attachments!,
      noScrollPhysics: true,
      itemBuilder: (ctx, index) {
        final attachment = vm.order.attachments![index];
        return AspectRatio(
          aspectRatio: 1,
          child: CustomImage(
            imageUrl: attachment.link!,
            canZoom: true,
            width: double.infinity,
            height: double.infinity,
            boxFit: BoxFit.cover,
          ).cornerRadius(8),
        );
      },
    );
  }
}

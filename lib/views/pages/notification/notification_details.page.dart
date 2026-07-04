import 'package:flutter/material.dart';
import 'package:chaskiy/models/notification.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationDetailsPage extends StatelessWidget {
  const NotificationDetailsPage({
    required this.notification,
    Key? key,
  }) : super(key: key);

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Notification Details".tr(),
      showAppBar: true,
      showLeadingAction: true,
      body: SafeArea(
        child: VStack(
          [
            //title
            "${notification.title}"
                .text
                .bold
                .xl2
                .fontFamily(GoogleFonts.nunito().fontFamily!)
                .make(),
            //time
            notification.formattedTimeStamp.text.medium
                .color(Colors.grey)
                .fontFamily(GoogleFonts.nunito().fontFamily!)
                .make()
                .pOnly(bottom: 10),
            //image
            if (notification.image != null && notification.image!.isNotEmpty)
              CustomImage(
                imageUrl: notification.image!,
                width: double.infinity,
                height: context.percentHeight * 30,
              ).py12(),

            //body
            "${notification.body}"
                .text
                .lg
                .fontFamily(GoogleFonts.nunito().fontFamily!)
                .make(),
          ],
        ).p20().scrollVertical(),
      ),
    );
  }
}

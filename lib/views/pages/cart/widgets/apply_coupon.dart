import 'package:flutter/material.dart';
import 'package:chaskiy/view_models/cart.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ApplyCoupon extends StatelessWidget {
  const ApplyCoupon(this.vm, {Key? key}) : super(key: key);

  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Coupon".tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (vm.isAuthenticated())
          CustomTextFormField(
            hintText: "Coupon Code".tr(),
            textEditingController: vm.couponTEC,
            errorText:
                vm.hasErrorForKey("coupon")
                    ? vm.error("coupon").toString()
                    : "",
            onChanged: vm.couponCodeChange,
            //el botón dice qué hace: antes era un visto suelto dentro del campo
            suffixIcon: Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 92,
                child: CustomButton(
                  title: "Apply".tr(),
                  height: 40,
                  shapeRadius: 12,
                  loading: vm.busy(vm.coupon) || vm.busy("coupon"),
                  onPressed: vm.canApplyCoupon ? vm.applyCoupon : null,
                ),
              ),
            ),
          )
        else
          EmptyState(auth: true, showImage: false, actionPressed: vm.openLogin),
      ],
    );
  }
}

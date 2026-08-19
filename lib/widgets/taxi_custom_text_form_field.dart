import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';

class TaxiCustomTextFormField extends StatelessWidget {
  const TaxiCustomTextFormField({
    required this.hintText,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onClearPressed,
    this.clear = false,
    Key? key,
  }) : super(key: key);
  final String hintText;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function onClearPressed;
  final bool clear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
        ),
        suffixIcon:
            clear && controller.text.isNotEmpty
                ? IconButton(
                  tooltip: 'Limpiar',
                  onPressed: () {
                    controller.clear();
                    onClearPressed();
                  },
                  icon: const Icon(Icons.close_rounded),
                )
                : null,
      ),
      autofocus: false,
      maxLines: 1,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }
}

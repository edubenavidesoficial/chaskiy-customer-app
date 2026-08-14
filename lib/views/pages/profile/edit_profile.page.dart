import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/services/validator.service.dart';
import 'package:chaskiy/view_models/edit_profile.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:chaskiy/widgets/forms/account_form_scaffold.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key, this.description});

  /// Texto de la cabecera.
  ///
  /// Se personaliza cuando la pantalla se abre por una razón concreta, como
  /// entrar con Google y quedarse sin teléfono en la cuenta.
  final String? description;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProfileViewModel>.reactive(
      viewModelBuilder: () => EditProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder:
          (context, model, child) => AccountFormScaffold(
            title: 'Editar perfil',
            description:
                description ??
                'Mantén actualizados tus datos para recibir pedidos y avisos.',
            icon: Icons.manage_accounts_rounded,
            child: Form(
              key: model.formKey,
              child: Column(
                children: [
                  _ProfilePhoto(model: model),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    textEditingController: model.nameTEC,
                    validator: FormValidator.validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CustomTextFormField(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    keyboardType: TextInputType.emailAddress,
                    textEditingController: model.emailTEC,
                    validator: FormValidator.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CustomTextFormField(
                    prefixIcon: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: model.showCountryDialPicker,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flag.fromString(
                              model.selectedCountry?.countryCode ?? 'EC',
                              width: 22,
                              height: 17,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '+${model.selectedCountry?.phoneCode ?? '593'}',
                            ),
                            const Icon(Icons.arrow_drop_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    labelText: 'Teléfono',
                    keyboardType: TextInputType.phone,
                    textEditingController: model.phoneTEC,
                    validator: FormValidator.validatePhone,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: 'Guardar cambios',
                      icon: Icons.check_rounded,
                      loading: model.isBusy,
                      onPressed: model.processUpdate,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.model});

  final EditProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image =
        model.newPhoto != null
            ? Image.file(model.newPhoto!, fit: BoxFit.cover)
            : CachedNetworkImage(
              imageUrl: model.currentUser?.photo ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Image.asset(AppImages.user),
              errorWidget: (_, __, ___) => Image.asset(AppImages.user),
            );

    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: InkWell(
        borderRadius: BorderRadius.circular(60),
        onTap: model.changePhoto,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: ClipOval(child: image),
            ),
            Positioned(
              right: -4,
              bottom: 2,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: colors.onPrimary,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

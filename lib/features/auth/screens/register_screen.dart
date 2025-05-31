import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_theme.dart';
import '../../../shared/formatters/phone_number_text_input_formatter.dart';
import '../../../shared/services/map_service.dart';
import '../../../shared/utils/form_validation.dart';
import '../../../shared/utils/select_date.dart';
import '../../../shared/widgets/custom_google_maps.dart';
import '../../../shared/widgets/custom_modal_bottom_sheet.dart';
import '../../../shared/widgets/politics_and_privacy.dart';
import '../services/services.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/social_sign_in.dart';
import 'auth_gate.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Regístrate para continuar'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizeScreen.width * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Iniciar sección con Redes Sociales o Servicios
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: sizeScreen.height * 0.005,
                  ),
                  child: const SocialSignIn(
                    googleActionText: 'Google',
                    facebookActionText: 'Facebook',
                    appleActionText: 'Apple',
                  ),
                ),

                //Indications
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: sizeScreen.height * 0.015,
                  ),
                  child: const Row(
                    children: [Text('O regístrate con tu correo electrónico')],
                  ),
                ),

                //Register form
                _RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final _dateController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    final validationForm = FormValidation();

    _direccionController.text = context.watch<RegisterService>().direction;

    _dateController.text = DateFormat(
      'd/MM/yyyy',
    ).format(context.watch<RegisterService>().birthday);

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: context.watch<RegisterService>().formKeyRegister,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Nombre',
            keyboardType: TextInputType.name,
            onChanged:
                (value) => {
                  context.read<RegisterService>().user.firstName = value,

                  //
                  context.read<RegisterService>().user.lastName = value,
                },
            validator: FormValidation().nameValidator(
              context.read<RegisterService>().user.firstName,
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.015),
          CustomTextFormField(
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            onChanged:
                (value) => context.read<RegisterService>().user.email = value,
            validator: FormValidation().emailValidator(
              context.read<RegisterService>().user.email,
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.015),
          CustomTextFormField(
            obscureText: context.watch<RegisterService>().obscureText,
            labelText: 'Contraseña',
            keyboardType: TextInputType.visiblePassword,
            onChanged:
                (value) =>
                    context.read<RegisterService>().user.password = value,
            validator: validationForm.passwordValidator(
              context.read<RegisterService>().user.password,
            ),
            suffixIcon: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.transparent,
                ),
              ),
              icon: Icon(
                context.watch<RegisterService>().obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: context.read<RegisterService>().toggleObscureText,
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.015),
          CustomTextFormField(
            labelText: 'Teléfono',
            keyboardType: TextInputType.phone,
            onChanged:
                (value) =>
                    context.read<RegisterService>().user.phoneNumber = value,
            inputFormatters: [PhoneNumberTextInputFormatter()],
            validator: FormValidation().phoneNumberValidator(
              context.read<RegisterService>().user.phoneNumber,
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.015),
          GestureDetector(
            onTap: () async {
              final mapService = Provider.of<MapService>(
                context,
                listen: false,
              );

              if (mapService.ubicacionActiva == false) {
                final positionUser = await mapService.getCurrentLocation(
                  context,
                );

                if (positionUser != null) {
                  mapService.posicionInicial = CameraPosition(
                    target: LatLng(
                      positionUser.latitude,
                      positionUser.longitude,
                    ),
                    zoom: 16.5,
                  );
                } else {
                  mapService.posicionInicial = const CameraPosition(
                    target: LatLng(18.459362, -69.994747),
                    zoom: 16.5,
                  );
                }
              }

              // ignore: use_build_context_synchronously

              context.pushNamed(CustomGoogleMaps.name);
            },
            child: CustomTextFormField(
              enabled: false,
              controller: _direccionController,
              labelText: 'Dirección de entrega',
              hintText: _direccionController.text,
              keyboardType: TextInputType.streetAddress,
              onChanged: (value) {
                _direccionController.text = value;
              },
              suffixIcon: IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                ),
                icon: const Icon(Icons.location_on_outlined),
                onPressed: () => context.pushNamed(CustomGoogleMaps.name),
              ),
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.015),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());

              final DateTime? fechaSeleccionada = await SelectDate()
                  .selectDate(context, context.read<RegisterService>().birthday)
                  .then((value) => value);

              if (fechaSeleccionada != null) {
                context.read<RegisterService>().birthday = fechaSeleccionada;
                _dateController.text = DateFormat(
                  'd/MM/yyyy',
                ).format(fechaSeleccionada);
              } else {
                return;
              }
            },
            child: CustomTextFormField(
              enabled: false,
              controller: _dateController,
              hintText: _dateController.text,
              labelText: 'Fecha de Nacimiento',
              keyboardType: TextInputType.datetime,
              onChanged: (value) {
                _dateController.text = value;
              },
              suffixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.01),

          // Políticas de privacidad
          CheckboxListTile(
            value: context.watch<RegisterService>().policiesAndTerms,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            title: RichText(
              text: TextSpan(
                style: TextStyle(letterSpacing: 0.3),
                children: <InlineSpan>[
                  const TextSpan(text: 'Acepta los '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        // var url = Uri.parse(
                        //     'https://jeelystore.com/politica-privacidad');
                        // if (await canLaunchUrl(url)) {
                        //   await launchUrl(url);
                        // } else {
                        //   throw 'Could not launch $url';
                        // }

                        showCustomModalBottomSheet(
                          context,
                          'Términos y políticas',
                          const PoliticsAndPrivacy(),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Términos y Condiciones',
                          style: TextStyle(
                            color: AppColors.info,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' y de la '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        // var url = Uri.parse(
                        //     'https://jeelystore.com/politica-privacidad');
                        // if (await canLaunchUrl(url)) {
                        //   await launchUrl(url);
                        // } else {
                        //   throw 'Could not launch $url';
                        // }

                        showCustomModalBottomSheet(
                          context,
                          'Términos y políticas',
                          const PoliticsAndPrivacy(),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Política de Privacidad',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onChanged: (bool? value) {
              context.read<RegisterService>().policiesAndTerms = value!;
            },
          ),
          SizedBox(height: sizeScreen.height * 0.01),
          FilledButton(
            onPressed:
                context.select<RegisterService, bool>(
                      (loginService) => loginService.isLoading,
                    )
                    ? null
                    : context.watch<RegisterService>().policiesAndTerms
                    ? () async {
                      // try {
                      //   final response = await context
                      //       .read<RegisterService>()
                      //       .createUserWithEmailAndPassword(
                      //           context.read<RegisterService>().user.email!,
                      //           context
                      //               .read<RegisterService>()
                      //               .user
                      //               .password!);

                      //   if (response != null) {
                      //     Future.delayed(const Duration(seconds: 1))
                      //         .then((_) {
                      //       if (Navigator.canPop(context)) {
                      //         context.pushReplacementNamed(AuthGate.name);
                      //       }
                      //     });
                      //   }
                      // } catch (e) {
                      //   Future.delayed(const Duration(seconds: 1))
                      //       .then((_) {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text(e.toString())),
                      //     );
                      //   });
                      // }
                    }
                    : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debes aceptar los términos y condiciones',
                          ),
                        ),
                      );
                    },
            child: Text(
              context.watch<RegisterService>().isLoading
                  ? 'Espere...'
                  : 'Crear cuenta',
            ),
          ),
          SizedBox(height: sizeScreen.height * 0.05),
        ],
      ),
    );
  }
}

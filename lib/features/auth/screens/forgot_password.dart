import 'package:flutter/material.dart';

import '../../../core/config/app_theme.dart';
import '../../../shared/utils/form_validation.dart';
import '../widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const String name = 'forgot-password';
  const ForgotPasswordScreen({super.key});

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
        title: Text(
          'Recuperar contraseña',
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizeScreen.width * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: sizeScreen.height * 0.03),
              const Text(
                'Ingrese su correo electrónico de registro y le enviaremos un enlace para recuperar su contraseña.',
              ),
              SizedBox(height: sizeScreen.height * 0.03),
              _ForgotPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final sizeScreen = MediaQuery.of(context).size;

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Correo electrónico',
            hintText: 'Ejemplo: usuario@correo.com',
            validator: (value) => FormValidation().emailValidator(value),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Lógica para enviar el enlace de recuperación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enlace enviado al correo')),
                );
              }
            },
            child: Text('Recuperar contraseña'),
          ),
          SizedBox(height: sizeScreen.height * 0.05),
          Text.rich(
            TextSpan(
              text: '¿No puedes acceder a tu cuenta?',
              children: [
                TextSpan(
                  text: ' FAQ',
                  style: const TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                  // onTap puede ser implementado aquí si es necesario
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

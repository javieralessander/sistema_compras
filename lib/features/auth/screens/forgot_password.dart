import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../shared/utils/form_validation.dart';
import '../widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const String name = 'forgotPassword';
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_reset, size: 64, color: AppColors.info),
                        const SizedBox(height: 32),
                        const Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Ingrese su correo electrónico de registro y le enviaremos un enlace para recuperar su contraseña.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _ForgotPasswordForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Correo electrónico',
            hintText: 'Ejemplo: usuario@correo.com',
            controller: emailController,
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
            child: const Text('Recuperar contraseña'),
          ),
          const SizedBox(height: 32),
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
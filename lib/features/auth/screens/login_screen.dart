import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_theme.dart';
import '../../../shared/utils/form_validation.dart';
import '../services/login_service.dart';
import '../widgets/custom_text_form_field.dart';
import 'auth_gate.dart';
import 'forgot_password.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen
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
                        SvgPicture.asset('assets/svgs/sicom.svg', height: 64),
                        const SizedBox(height: 32),
                        const Text(
                          'Inicia sesión para continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LoginForm(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => context.pushNamed(RegisterScreen.name),
                              child: const Text(
                                "Crear cuenta",
                                style: TextStyle(color: AppColors.info),
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => context.pushNamed(
                                    ForgotPasswordScreen.name,
                                  ),
                              child: const Text(
                                "¿Necesitas ayuda?",
                                style: TextStyle(color: AppColors.info),
                              ),
                            ),
                          ],
                        ),
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

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginService = context.read<LoginService>();
    final validationForm = FormValidation();
    GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKeyLogin,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginService.email = value,
            validator: FormValidation().emailValidator(loginService.email),
            // borderRadius: 32, // Asegúrate de que tu widget soporte esto
            // prefixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            obscureText: loginService.obscureText,
            labelText: 'Contraseña',
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => loginService.password = value,
            validator: validationForm.passwordValidator(loginService.password),
            // borderRadius: 32, // Asegúrate de que tu widget soporte esto
            // prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              style: IconButton.styleFrom(
                foregroundColor: AppColors.info,
                backgroundColor: Colors.transparent,
              ),
              icon: Icon(
                loginService.obscureText
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: loginService.toggleObscureText,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                backgroundColor: AppColors.info,
              ),
              onPressed:
                  context.select<LoginService, bool>(
                        (loginService) => loginService.isLoading,
                      )
                      ? null
                      : () async {
                        final loginService = context.read<LoginService>();
                        final success = await loginService.login(context);
                        if (success) {
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          if (context.mounted) {
                            context.pushReplacementNamed(AuthGate.name);
                          }
                        }
                      },
              child: Text(
                context.watch<LoginService>().isLoading
                    ? 'Espere...'
                    : 'Iniciar sesión',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

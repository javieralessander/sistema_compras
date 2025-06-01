import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_theme.dart';
import '../../../shared/utils/form_validation.dart';
import '../services/services.dart';
import '../widgets/custom_text_form_field.dart';
import 'auth_gate.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register';

  const RegisterScreen({super.key});

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
                        SvgPicture.asset('assets/svgs/sicom.svg', height: 64),
                        const SizedBox(height: 32),
                        const Text(
                          'Regístrate para continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _RegisterForm(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => context.pushReplacementNamed(
                                    LoginScreen.name,
                                  ),
                              child: const Text(
                                "¿Ya tienes cuenta?",
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
class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final formKeyRegister = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerService = context.watch<RegisterService>();
    final validationForm = FormValidation();

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKeyRegister,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Nombre',
            keyboardType: TextInputType.name,
            controller: nameController,
            onChanged: (value) => registerService.user.name = value,
            validator: validationForm.nameValidator(nameController.text),
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            onChanged: (value) => registerService.user.email = value,
            validator: FormValidation().emailValidator,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            obscureText: registerService.obscureText,
            labelText: 'Contraseña',
            keyboardType: TextInputType.visiblePassword,
            controller: passwordController,
            onChanged: (value) => registerService.user.password = value,
            validator: validationForm.passwordValidator(passwordController.text),
            suffixIcon: IconButton(
              style: IconButton.styleFrom(
                foregroundColor: AppColors.info,
                backgroundColor: Colors.transparent,
              ),
              icon: Icon(
                registerService.obscureText
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: registerService.toggleObscureText,
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
              onPressed: context.select<RegisterService, bool>(
                        (registerService) => registerService.isLoading,
                      )
                      ? null
                      : () async {
                          final registerService = context.read<RegisterService>();
                          final form = formKeyRegister.currentState;
                          if (form != null && form.validate()) {
                            final success = await registerService
                                .createUserWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text,
                                );
                            if (success && context.mounted) {
                              context.pushReplacementNamed(AuthGate.name);
                            }
                          }
                        },
              child: Text(
                context.watch<RegisterService>().isLoading
                    ? 'Espere...'
                    : 'Crear cuenta',
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
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/models/user.dart';


// import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterService extends ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();

  bool isValidForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  User user = User(
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      direction: '',
      phoneNumber: '',
      location: const GeoPoint(0, 0),
      birthday: DateTime.now());

  bool _policiesAndTerms = false;
  bool get policiesAndTerms => _policiesAndTerms;
  set policiesAndTerms(bool value) {
    _policiesAndTerms = value;
    notifyListeners();
  }

  String get direction => user.direction!;
  set direction(String value) {
    user.direction = value;
    notifyListeners();
  }

  DateTime get birthday => user.birthday!;
  set birthday(DateTime value) {
    user.birthday = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  // Future<UserCredential?> createUserWithEmailAndPassword(
  //     String emailAddress, String password) async {
  //   isLoading = true;
  //   try {
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: emailAddress,
  //       password: password,
  //     );

  //     secureStorage.write(key: 'token', value: userCredential.user!.uid);

  //     if (userCredential.user != null) {
  //       final Map<String, dynamic> userData = {
  //         'uid': userCredential.user!.uid,
  //         'photoURL': '',
  //         'displayName': '${user.firstName} ${user.lastName}',
  //         'email': emailAddress,
  //         'numberPhone': cleaningNumberPhone(user.phoneNumber!),
  //         'direction': direction,
  //         'coordinates': user.location,
  //         'dateOfBirthday': birthday,
  //       };

  //       userCredential.user!
  //           .updateDisplayName('${user.firstName} ${user.lastName}');

  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userCredential.user!.uid)
  //           .set(userData);

  //       await AuthService().sendEmailVerification();
  //       isLoading = false;
  //       return userCredential;
  //     } else {
  //       isLoading = false;
  //       throw RegistrationException('Error de registro');
  //     }
  //   } catch (e) {
  //     isLoading = false;
  //     if (e is FirebaseAuthException) {
  //       throw RegistrationException(getCreateUserErrorMessage(e.code));
  //     } else {
  //       throw RegistrationException(e.toString());
  //     }
  //   }
  // }

  String getCreateUserErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'La dirección de correo electrónico ya está siendo utilizada por otra cuenta.';
      case 'invalid-email':
        return 'La dirección de correo electrónico no es válida.';
      case 'operation-not-allowed':
        return 'La operación de registro de usuarios con correo electrónico y contraseña no está habilitada.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return 'Ha ocurrido un error desconocido.';
    }
  }
}

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);
}

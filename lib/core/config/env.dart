import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }
    return '.env.development';
  }

  static String get androidGoogleKey {
    return dotenv.env['androidGoogleKey'] ?? 'androidGoogleKey not found!';
  }

  static String get odooApiUrl {
    return dotenv.env['odooApiUrl'] ?? 'odooApiUrl not found!';
  }

  static int get jsonrpc {
    try {
      return int.parse(dotenv.env['jsonrpc'] ?? '2');
    } catch (e) {
      return 2;
    }
  }

  static String get postgres_db {
    return dotenv.env['postgres_db'] ?? 'postgres_db not found!';
  }

  static String get googleMapsApiUrl {
    return dotenv.env['googleMapsApiUrl'] ?? 'googleMapsApiUrl not found!';
  }

  static String get iosGoogleKey {
    return dotenv.env['iosGoogleKey'] ?? 'iosGoogleKey not found!';
  }

  static String get appName {
    return dotenv.env['application.name'] ?? 'App';
  }

  static String get appShortName {
    return dotenv.env['application.shortName'] ?? 'App';
  }
}

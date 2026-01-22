import 'package:flutter/foundation.dart';

const String stripePublishablekey ="pk_test_51SOoYlPzFOvAOgSvv1Q7GmHYaUUh2zlBqKefPhuq81bpy9zNGo5QfWo8gnIKxkpYmrk3v9tD2sZNPpkNKby4xWZQ00kcIPRkHx";

String get backendUrl {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return "http://10.0.2.2:5000";
  }
  return "http://localhost:5000";
}

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:green_bush/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(const MyApp());
}

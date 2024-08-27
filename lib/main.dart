import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Text('AutoCare', textDirection: TextDirection.ltr,));
  //sample connection to discord
}


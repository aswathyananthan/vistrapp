import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vistr_app/firebase_options.dart';
import 'package:vistr_app/utils/auth/auth.dart';
import 'package:vistr_app/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().userStatus,
      // initialData: null,
      initialData: FirebaseAuth.instance.currentUser,
      catchError: (context, error) {
        print(error);
        return null;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}

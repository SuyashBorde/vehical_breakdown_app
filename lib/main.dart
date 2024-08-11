import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vehical_breakdown_app/contactList.dart';
import 'package:vehical_breakdown_app/firebase_options.dart';
import 'package:vehical_breakdown_app/login_page.dart';
import 'package:vehical_breakdown_app/register_page.dart';
import 'package:vehical_breakdown_app/save_contact_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehical_breakdown_app/smsverification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/ContactList': (context) => const ContactListPage(),
        '/SaveContacts': (context) => const SaveContactsPage(),
        '/SmsVerification': (context) => const SmsVerification(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data != null) {
          return const SmsVerification();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

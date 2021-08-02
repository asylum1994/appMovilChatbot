import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:segundo_parcial_is1/agente/view/detalle_cita.dart';
import 'package:segundo_parcial_is1/usuario/view/inicio_view.dart';
import 'package:segundo_parcial_is1/usuario/view/login_view.dart';
import 'package:segundo_parcial_is1/usuario/view/registro_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute:
            FirebaseAuth.instance.currentUser != null ? 'Inicio' : 'Login',
        routes: <String, WidgetBuilder>{
          'Inicio': (BuildContext context) => Inicio(),
          'Login': (BuildContext context) => Login(),
          'Registro': (BuildContext context) => Registro(),
          'DetalleCita': (BuildContext context) => DetalleCita(),
        });
  }
}

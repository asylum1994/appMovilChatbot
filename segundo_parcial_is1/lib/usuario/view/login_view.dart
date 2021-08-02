import 'package:flutter/material.dart';
import 'package:segundo_parcial_is1/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _email;
  String _password;
  final auth = new AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black12,
      body: _loginPage(),
    );
  }

  Widget _loginPage() {
    return ListView(
      children: [
        SizedBox(
          height: 50,
        ),
        _titulo(),
        _icono(),
        SizedBox(
          height: 20,
        ),
        _inputEmail(),
        SizedBox(
          height: 20,
        ),
        _inputPassword(),
        SizedBox(
          height: 20,
        ),
        _buttonLogin(),
        SizedBox(
          height: 10,
        ),
        _textoMensaje(),
        _linkRegistro(),
      ],
    );
  }

  Widget _titulo() {
    return Container(
      child: Text('Iniciar Sesion',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.cyan, fontSize: 50, fontWeight: FontWeight.bold)),
    );
  }

  Widget _icono() {
    return Container(
      child: Icon(
        Icons.account_circle,
        color: Colors.cyan,
        size: 150,
      ),
    );
  }

  Widget _inputEmail() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) {
            _email = value;
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
                borderRadius: BorderRadius.circular(10)),
            hintText: 'Ingresar email',
            hintStyle:
                TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget _inputPassword() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) {
          _password = value;
        },
        obscureText: true,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
                borderRadius: BorderRadius.circular(10)),
            hintText: 'Ingresar password',
            hintStyle:
                TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 130),
      child: ElevatedButton(
        child: Text('Ingresar'),
        onPressed: () async {
          AuthService auth = AuthService();
          User user = await (auth.login(
            _email,
            _password,
            context,
          ));
          if (user != null) {
            showToast(context, "usuario encontrado");
            Navigator.popAndPushNamed(context, 'Inicio');
          } else {
            showToast(context, "usuario no encontrado");
          }
        },
      ),
    );
  }

  Widget _textoMensaje() {
    return Container(
      child: Text(
        '¿ aun no te encuentras registrad@ ?',
        style: TextStyle(
            color: Colors.cyan, fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _linkRegistro() {
    return Container(
      child: TextButton(
        child: Text(
          'Registrate !!!',
          style: TextStyle(color: Colors.cyan, fontSize: 20),
        ),
        onPressed: () {
          Navigator.popAndPushNamed(context, 'Registro');
        },
      ),
    );
  }

  void showToast(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.deepOrangeAccent,
      content: Text(mensaje),
      duration: Duration(seconds: 5),
    ));
  }
}

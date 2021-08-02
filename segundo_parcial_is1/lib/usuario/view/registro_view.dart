import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:segundo_parcial_is1/service/auth_service.dart';
import 'package:segundo_parcial_is1/usuario/model/registro_model.dart';
import 'package:segundo_parcial_is1/usuario/provider/registro_provider.dart';
import 'package:segundo_parcial_is1/usuario/view/login_view.dart';

class Registro extends StatefulWidget {
  Registro({Key key}) : super(key: key);

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  String _name;
  String _email;
  String _password;
  final _registroModel = new UsuarioModel();
  final _registroProvider = new UsuarioProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black12,
      body: _registroPage(),
    );
  }

  Widget _registroPage() {
    return ListView(
      children: [
        SizedBox(
          height: 50,
        ),
        _titulo(),
        _icono(),
        _inputName(),
        SizedBox(
          height: 20,
        ),
        _inputEmail(),
        SizedBox(
          height: 20,
        ),
        _inputPassword(),
        SizedBox(
          height: 10,
        ),
        _buttonRegistro(),
        SizedBox(
          height: 30,
        ),
        _textoMensaje(),
        _linkSesion(),
      ],
    );
  }

  Widget _titulo() {
    return Container(
      child: Text('Registrate',
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

  Widget _inputName() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) {
            _name = value;
          },
          controller: _nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
                borderRadius: BorderRadius.circular(10)),
            hintText: 'Ingresar nombre',
            hintStyle:
                TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget _inputEmail() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) {
            _email = value;
          },
          controller: _emailController,
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
        controller: _passwordController,
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

  Widget _buttonRegistro() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 130),
      child: ElevatedButton(
        child: Text('Registrarse'),
        onPressed: () async {
          AuthService auth = AuthService();
          UserCredential userCredential =
              await auth.register(_email, _password, context);
          if (userCredential.user != null) {
            _registroModel.idu = userCredential.user.uid;
            _registroModel.nombre = _name;
            _registroModel.email = _email;
            _registroModel.password = _password;
            _registroProvider.crearUsuario(_registroModel).then((value) {
              showToast(context, 'el registro fue exitoso !!!!');
              _nameController.clear();
              _emailController.clear();
              _passwordController.clear();
            });
          } else {
            showToast(context, 'no se pudo completar el registro');
          }
        },
      ),
    );
  }

  Widget _textoMensaje() {
    return Container(
      child: Text(
        '¿ tienes una cuenta ?',
        style: TextStyle(
            color: Colors.cyan, fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _linkSesion() {
    return Container(
      child: TextButton(
        child: Text(
          'inicia sesion!!!',
          style: TextStyle(color: Colors.cyan, fontSize: 20),
        ),
        onPressed: () {
          Navigator.popAndPushNamed(context, 'Login');
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

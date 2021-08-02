import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segundo_parcial_is1/usuario/model/registro_model.dart';

class UsuarioProvider {
  final _url = 'https://do-parcial-is2-default-rtdb.firebaseio.com';

  Future crearUsuario(UsuarioModel usuario) async {
    final url = Uri.parse('$_url/usuario.json');
    final resp = await http.post(url, body: usuarioModelToJson(usuario));
    return resp;
  }

  Future<UsuarioModel> getUsuario(String idu) async {
    UsuarioModel temporal;
    final url = Uri.parse('$_url/usuario.json');
    final resp = await http.get(url);
    final Map<String, dynamic> decodeData = json.decode(resp.body);
    if (decodeData == null) {
      return null;
    }
    decodeData.forEach((id, value) {
      final tempModel = UsuarioModel.fromJson(value);
      tempModel.id = id;
      if (idu == tempModel.idu) {
        temporal = tempModel;
      }
    });
    return temporal;
  }
}

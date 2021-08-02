import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segundo_parcial_is1/usuario/model/actividad_model.dart';

class ActividadProvider {
  final _url = 'https://do-parcial-is2-default-rtdb.firebaseio.com';

  Future<List<ActividadModel>> getActividad() async {
    final List<ActividadModel> lista = [];
    final url = Uri.parse('$_url/actividad.json');
    final resp = await http.get(url);
    final Map<String, dynamic> decodeData = json.decode(resp.body);
    if (decodeData == null) {
      return null;
    }
    decodeData.forEach((id, value) {
      final tempModel = ActividadModel.fromJson(value);
      tempModel.id = id;
      lista.add(tempModel);
    });
    return lista;
  }
}

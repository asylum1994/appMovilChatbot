import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segundo_parcial_is1/agente/model/cita_model.dart';
import 'package:segundo_parcial_is1/agente/model/horario_model.dart';

class CitaProvider {
  final _url = 'https://do-parcial-is2-default-rtdb.firebaseio.com';

  Future crearCita(CitaModel cita) async {
    final url = Uri.parse('$_url/cita.json');
    final resp = await http.post(url, body: citaModelToJson(cita));
    return resp;
  }

  Future<HorarioModel> getHorario(String turno) async {
    HorarioModel temporal;
    final url = Uri.parse('$_url/horario.json');
    final resp = await http.get(url);
    final Map<String, dynamic> decodeData = json.decode(resp.body);
    if (decodeData == null) {
      return null;
    }
    decodeData.forEach((id, value) {
      final tempModel = HorarioModel.fromJson(value);
      tempModel.id = id;
      if (tempModel.periodo == turno) {
        temporal = tempModel;
      }
    });
    return temporal;
  }

  Future<List<CitaModel>> getListaCita(String email) async {
    final List<CitaModel> lista = [];
    final url = Uri.parse('$_url/cita.json');
    final resp = await http.get(url);
    final Map<String, dynamic> decodeData = json.decode(resp.body);
    if (decodeData == null) {
      return null;
    }
    decodeData.forEach((id, value) {
      final tempModel = CitaModel.fromJson(value);
      tempModel.id = id;
      if (email == tempModel.idu) {
        lista.add(tempModel);
      }
    });
    return lista;
  }
}

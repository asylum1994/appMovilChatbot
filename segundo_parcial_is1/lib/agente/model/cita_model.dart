import 'dart:convert';

CitaModel citaModelFromJson(String str) => CitaModel.fromJson(json.decode(str));

String citaModelToJson(CitaModel data) => json.encode(data.toJson());

class CitaModel {
  String id;
  String idu;
  String especialista;
  String nombre;
  String telefono;
  String turno;
  String estado;
  String fecha;

  CitaModel({
    this.id,
    this.idu,
    this.especialista,
    this.nombre,
    this.telefono,
    this.turno,
    this.estado = 'activo',
    this.fecha,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) => new CitaModel(
        id: json["id"],
        idu: json['idu'],
        especialista: json["especialista"],
        nombre: json["nombre"],
        telefono: json["telefono"],
        turno: json["turno"],
        estado: json["estado"],
        fecha: json['fecha'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        'idu': idu,
        "especialista": especialista,
        "nombre": nombre,
        "telefono": telefono,
        "turno": turno,
        "estado": estado,
        "fecha": fecha,
      };
}

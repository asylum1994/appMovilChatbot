import 'dart:convert';

ActividadModel actividadModelFromJson(String str) =>
    ActividadModel.fromJson(json.decode(str));

String actividadModelToJson(ActividadModel data) => json.encode(data.toJson());

class ActividadModel {
  String id;
  String titulo;
  String descripcion;
  String fecha;
  String hora;
  String foto;

  ActividadModel({
    this.id,
    this.titulo,
    this.descripcion,
    this.fecha,
    this.hora,
    this.foto = '',
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) =>
      new ActividadModel(
        id: json["id"],
        titulo: json["titulo"],
        descripcion: json["descripcion"],
        fecha: json["fecha"],
        hora: json["hora"],
        foto: json["foto"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titulo": titulo,
        "descripcion": descripcion,
        "fecha": fecha,
        "hora": hora,
        "foto": foto,
      };
}

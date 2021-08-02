import 'dart:convert';

HorarioModel horarioModelFromJson(String str) =>
    HorarioModel.fromJson(json.decode(str));

String horarioModelToJson(HorarioModel data) => json.encode(data.toJson());

class HorarioModel {
  String id;
  String hora_inicio;
  String hora_fin;
  String periodo;
  HorarioModel({this.id, this.hora_inicio, this.hora_fin, this.periodo});

  factory HorarioModel.fromJson(Map<String, dynamic> json) => new HorarioModel(
        id: json["id"],
        hora_inicio: json["hora_inicio"],
        hora_fin: json["hora_fin"],
        periodo: json["periodo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hora_inicio": hora_inicio,
        "hora_fin": hora_fin,
        "periodo": periodo,
      };
}

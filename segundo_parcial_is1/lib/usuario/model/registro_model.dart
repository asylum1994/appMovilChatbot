import 'dart:convert';

UsuarioModel usuarioModelFromJson(String str) =>
    UsuarioModel.fromJson(json.decode(str));

String usuarioModelToJson(UsuarioModel data) => json.encode(data.toJson());

class UsuarioModel {
  String id;
  String idu;
  String nombre;
  String email;
  String password;
  String foto;

  UsuarioModel({
    this.id,
    this.idu,
    this.nombre,
    this.email,
    this.password,
    this.foto = '',
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => new UsuarioModel(
        id: json["id"],
        idu: json["idu"],
        nombre: json["nombre"],
        email: json["email"],
        password: json["password"],
        foto: json["foto"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "idu": idu,
        "nombre": nombre,
        "email": email,
        "password": password,
        "foto": foto,
      };
}

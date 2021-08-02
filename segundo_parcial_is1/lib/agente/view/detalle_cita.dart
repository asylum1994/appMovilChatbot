import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:segundo_parcial_is1/agente/model/cita_model.dart';
import 'package:segundo_parcial_is1/agente/model/horario_model.dart';
import 'package:segundo_parcial_is1/agente/provider/cita_provider.dart';

class DetalleCita extends StatefulWidget {
  DetalleCita({Key key}) : super(key: key);

  @override
  _DetalleCitaState createState() => _DetalleCitaState();
}

class _DetalleCitaState extends State<DetalleCita> {
  String email = FirebaseAuth.instance.currentUser.email;
  final _citaProvider = new CitaProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('detalle de citas'),
      ),
      body: detalleCitaPage(),
    );
  }

  Widget detalleCitaPage() {
    return FutureBuilder(
        future: _citaProvider.getListaCita(email),
        builder:
            (BuildContext context, AsyncSnapshot<List<CitaModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView(children: listaCita(snapshot.data));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  List<Widget> listaCita(List<CitaModel> cita) {
    List<Widget> listaTemp = [];
    cita.forEach((element) {
      Widget temp = Padding(
          padding: EdgeInsets.all(8),
          child: Card(
            elevation: 40,
            color: element.estado == 'activo' ? Colors.green : Colors.redAccent,
            child: ListTile(
              leading: Icon(
                Icons.account_box_outlined,
                color: Colors.white,
              ),
              trailing: Icon(Icons.local_hospital, color: Colors.white),
              title: Text(
                'Cita',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Table(
                children: [
                  TableRow(children: [
                    Text(
                      'nombre: ' + element.nombre,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                  TableRow(children: [
                    Text(
                      'telefono: ' + element.telefono,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                  TableRow(children: [
                    Text(
                      'turno: ' + element.turno,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                  TableRow(children: [
                    Text(
                      'fecha: ' + element.fecha,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                  TableRow(children: [
                    FutureBuilder(
                        future: _citaProvider.getHorario(element.turno),
                        builder: (BuildContext context,
                            AsyncSnapshot<HorarioModel> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'horario : ' +
                                  snapshot.data.hora_inicio +
                                  ' - ' +
                                  snapshot.data.hora_fin,
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ]),
                  TableRow(children: [
                    Text(
                      'estado de la cita: ' + element.estado,
                      style: TextStyle(color: Colors.white),
                    )
                  ]),
                ],
              ),
            ),
          ));

      listaTemp.add(temp);
    });
    return listaTemp;
  }
}

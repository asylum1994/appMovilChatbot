import 'dart:async';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2/intent.pb.dart';
import 'package:dialogflow_grpc/generated/google/protobuf/struct.pb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:segundo_parcial_is1/agente/model/cita_model.dart';
import 'package:segundo_parcial_is1/agente/provider/cita_provider.dart';
import 'package:segundo_parcial_is1/usuario/model/actividad_model.dart';
import 'package:segundo_parcial_is1/usuario/model/registro_model.dart';
import 'package:segundo_parcial_is1/usuario/provider/actividad_provider.dart';
import 'package:segundo_parcial_is1/usuario/provider/registro_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';

DialogflowGrpcV2Beta1 dialogflow;

class Inicio extends StatefulWidget {
  Inicio({Key key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final hora = new DateTime.now().hour;
  final minuto = new DateTime.now().minute;
  final actividadModel = new ActividadModel();
  final actividadProvider = new ActividadProvider();
  bool _recording = true;
  int _estado = 0;
  final _citaProvider = new CitaProvider();
  final _citaModel = new CitaModel();
  final _usuarioProvider = new UsuarioProvider();
  String idu = FirebaseAuth.instance.currentUser.uid;
  String email = FirebaseAuth.instance.currentUser.email;
  String valorTextfield = "";
  final List<ChatMensaje> _mensajes = [];
  final TextEditingController _textController = TextEditingController();

  bool _esGrabando = false;

  RecorderStream _grabadora = RecorderStream();
  StreamSubscription _grabadoraStatus;
  StreamSubscription<List<int>> _audioStreamSubscripcion;
  BehaviorSubject<List<int>> _audioStream;

  @override
  void initState() {
    super.initState();
    _estado = 0;
    inicioPlugin();
  }

  void estadoTap(int valor) {
    setState(() {
      _estado = valor;
    });
  }

// inicio codigo chatbot
  @override
  void dispose() {
    _grabadoraStatus?.cancel();
    _audioStreamSubscripcion?.cancel();
    super.dispose();
  }

  Future<void> inicioPlugin() async {
    _grabadoraStatus = _grabadora.status.listen((status) {
      if (mounted)
        setState(() {
          _esGrabando = status == SoundStreamStatus.Playing;
        });
    });

    await Future.wait([_grabadora.initialize()]);
    final cuentaServicio = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/service\.json'))}');
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(cuentaServicio);
  }

  void pararStream() async {
    await _grabadora.stop();
    await _audioStreamSubscripcion?.cancel();
    await _audioStream?.close();
  }

  void identificadoEnviado(texto) async {
    _textController.clear();

    ChatMensaje mensaje = ChatMensaje(
      texto: texto,
      nombre: email,
      tipo: true,
    );

    setState(() {
      _mensajes.insert(0, mensaje);
    });

    DetectIntentResponse datos = await dialogflow.detectIntent(texto, 'es-419');
    String textocompleto = datos.queryResult.fulfillmentText;
    String tipoIntent = datos.queryResult.intent
        .displayName; // se obtiene el nombre del intent de respuesta
    if (textocompleto.isNotEmpty) {
      ChatMensaje botMensaje = ChatMensaje(
        texto: textocompleto,
        nombre: "Asistente",
        tipo: false,
      );

      setState(() {
        _mensajes.insert(0, botMensaje);
      });
    }

    if (textocompleto == "en un momento reservaremos su cita....") {
      final nombre =
          datos.queryResult.ensureParameters().fields['nombre'].stringValue;
      final telefono =
          datos.queryResult.ensureParameters().fields['telefono'].numberValue;
      final turno =
          datos.queryResult.ensureParameters().fields['turno'].stringValue;
      _citaModel.idu = email;
      _citaModel.nombre = nombre;
      _citaModel.telefono = telefono.toString();
      _citaModel.turno = turno;
      _citaModel.especialista = 'doctor colanzi';
      _citaModel.fecha = '01/08/2021';
      _citaProvider.crearCita(_citaModel).then((value) => {});
      ChatMensaje botMensajeRegistro = ChatMensaje(
        texto: 'se ha registrado su cita exitosamente !!!!',
        nombre: "Asistente",
        tipo: false,
      );
      setState(() {
        _mensajes.insert(0, botMensajeRegistro);
      });

      _citaProvider.getHorario(turno).then((value) => {
            setState(() {
              _mensajes.insert(
                  0,
                  ChatMensaje(
                      texto: nombre.toUpperCase() +
                          ' con nro telefono : ' +
                          telefono.toString().toUpperCase() +
                          ' tu cita es para el: 01/08/2021 ' +
                          'puede asistir entre los horarios ' +
                          value.hora_inicio.toUpperCase() +
                          ' - ' +
                          value.hora_fin.toUpperCase() +
                          ' por la ' +
                          value.periodo.toUpperCase(),
                      nombre: 'asistente',
                      tipo: false));
            })
          });
    }
  }

  void manejoStream() async {
    _grabadora.start();

    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscripcion = _grabadora.audioStream.listen((data) {
      _audioStream.add(data);
    });

    var predisposicionLista = SpeechContextV2Beta1(phrases: [
      'Dialogflow CX',
      'Dialogflow Essentials',
      'Action Builder',
      'HIPAA'
    ], boost: 20.0);

    var configuracion = InputConfigV2beta1(
        encoding: 'AUDIO_ENCODING_LINEAR_16',
        languageCode: 'es-419',
        sampleRateHertz: 16000,
        singleUtterance: false,
        speechContexts: [predisposicionLista]);

    final respuestaStream =
        dialogflow.streamingDetectIntent(configuracion, _audioStream);

    respuestaStream.listen((data) {
      setState(() {
        String transcripcion = data.recognitionResult.transcript;
        String textoConsulta = data.queryResult.queryText;
        String textoCompleto = data.queryResult.fulfillmentText;
        print(data.queryResult.intent.displayName);
        print(textoConsulta);
        print(textoCompleto);
        if (textoCompleto.isNotEmpty) {
          ChatMensaje mensaje = new ChatMensaje(
            texto: textoConsulta,
            nombre: email,
            tipo: true,
          );

          ChatMensaje botMensaje = new ChatMensaje(
            texto: textoCompleto,
            nombre: "Asistente",
            tipo: false,
          );

          if (textoCompleto == "en un momento reservaremos su cita....") {
            final nombre = data.queryResult
                .ensureParameters()
                .fields['nombre']
                .stringValue;
            final telefono = data.queryResult
                .ensureParameters()
                .fields['telefono']
                .numberValue;
            final turno =
                data.queryResult.ensureParameters().fields['turno'].stringValue;
            _citaModel.idu = email;
            _citaModel.nombre = nombre;
            _citaModel.telefono = telefono.toString();
            _citaModel.turno = turno;
            _citaModel.especialista = 'doctor colanzi';
            _citaModel.fecha = '01/08/2021';
            _citaProvider.crearCita(_citaModel).then((value) => {});
            ChatMensaje botMensajeRegistro = ChatMensaje(
              texto: 'se ha registrado su cita exitosamente !!!!',
              nombre: "Asistente",
              tipo: false,
            );
            setState(() {
              _mensajes.insert(0, botMensajeRegistro);
            });

            _citaProvider.getHorario(turno).then((value) => {
                  setState(() {
                    _mensajes.insert(
                        0,
                        ChatMensaje(
                            texto: nombre.toUpperCase() +
                                ' con nro telefono : ' +
                                telefono.toString().toUpperCase() +
                                ' tu cita es para el: 01/08/2021 ' +
                                'puede asistir entre los horarios ' +
                                value.hora_inicio.toUpperCase() +
                                ' - ' +
                                value.hora_fin.toUpperCase() +
                                ' por la ' +
                                value.periodo.toUpperCase(),
                            nombre: 'asistente',
                            tipo: false));
                  })
                });
          }

          _mensajes.insert(0, mensaje);
          _textController.clear();
          _mensajes.insert(0, botMensaje);
        }
        if (transcripcion.isNotEmpty) {
          _textController.text = transcripcion;
        }
      });
    }, onError: (e) {
      //print(e);
    }, onDone: () {
      //print('listo');
    });
  }

  Widget listaMensaje() {
    return Flexible(
        child: ListView.builder(
      padding: EdgeInsets.all(8.0),
      reverse: true,
      itemBuilder: (BuildContext context, int index) => _mensajes[index],
      itemCount: _mensajes.length,
    ));
  }

// fin codigo chatbot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2do parcial I.S.1'),
        backgroundColor: Colors.cyan,
      ),
      body: _estado == 0 ? _actividadPage() : _chatPage(),
      drawer: Drawer(
        child: ListView(
          children: [
            _drawerHead(),
            _drawerBody(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _estado,
        onTap: estadoTap,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility), label: 'actividades'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: 'atencion al cliente'),
        ],
      ),
    );
  }

  Widget _drawerHead() {
    return SizedBox(
      height: 220,
      child: DrawerHeader(
        decoration: BoxDecoration(color: Colors.orangeAccent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              maxRadius: 55,
            ),
            FutureBuilder(
                future: _usuarioProvider.getUsuario(idu),
                builder: (BuildContext context,
                    AsyncSnapshot<UsuarioModel> snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(
                      title: Text(snapshot.data.nombre),
                      subtitle: Text(snapshot.data.email),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _drawerBody() {
    return Container(
      child: Column(
        children: [
          ListTile(
            onTap: () {},
            leading: Icon(Icons.home),
            title: Text('home'),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.account_box_outlined),
            title: Text('perfil'),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            onTap: () {
              setState(() {
                Navigator.pushNamed(context, 'DetalleCita');
              });
            },
            leading: Icon(Icons.home),
            title: Text('citas'),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          ListTile(
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                showToast(
                    context,
                    'usuario:' +
                        FirebaseAuth.instance.currentUser.email +
                        'a cerrado sesion');
              });
              Navigator.popAndPushNamed(context, 'Login');
            },
            leading: Icon(Icons.exit_to_app),
            title: Text('cerrar sesion'),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }

  Widget _actividadPage() {
    return FutureBuilder(
        future: actividadProvider.getActividad(),
        builder: (BuildContext context,
            AsyncSnapshot<List<ActividadModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView(children: listaActividad(snapshot.data));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  List<Widget> listaActividad(List<ActividadModel> actividadModel) {
    List<Widget> lista = [];
    actividadModel.forEach((element) {
      Widget temp =
          _cardActividad(element.titulo, element.descripcion, element.foto);
      lista.add(temp);
    });
    return lista;
  }

  // traer la cantidad de informacion de la base de datos
  /*List<Widget> listaActividad() {
    return;
  }*/

  Widget _cardActividad(String titulo, String descripcion, String foto) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          elevation: 20,
          child: ListTile(
            title: Text(
              '2do parcial I.S.1',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            subtitle: Column(
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: NetworkImage(foto),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(descripcion),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '20/07/2021',
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _chatPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        listaMensaje(),
        _inputChat(),
      ],
    );
  }

  Widget _inputChat() {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListTile(
        trailing: valorTextfield.length == 0
            ? Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(23))),
                child: _esGrabando
                    ? IconButton(
                        color: Colors.red,
                        icon: Icon(Icons.mic_off),
                        onPressed: () {
                          setState(() {
                            pararStream();
                          });
                        },
                      )
                    : IconButton(
                        color: Colors.blueAccent,
                        icon: Icon(Icons.mic),
                        onPressed: () {
                          setState(() {
                            manejoStream();
                          });
                        },
                      ),
              )
            : Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(23))),
                child: IconButton(
                  color: Colors.green,
                  icon: Icon(Icons.send),
                  onPressed: () {
                    valorTextfield = '';
                    identificadoEnviado(_textController.text);
                  },
                ),
              ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: _textController,
              onSubmitted: identificadoEnviado,
              onChanged: (valor) {
                setState(() {
                  valorTextfield = valor;
                });
              },
              maxLines: 4,
              decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'enviar mensaje....'),
            ),
          ),
        ),
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

  Widget buttoPrueba() {
    return MaterialButton(
      onPressed: () {},
      color: _recording ? Colors.grey : Colors.pink,
      textColor: Colors.white,
      child: Icon(Icons.mic, size: 60),
      shape: CircleBorder(),
      padding: EdgeInsets.all(25),
    );
  }
}

//------------------------------------
class ChatMensaje extends StatelessWidget {
  ChatMensaje({this.texto, this.nombre, this.tipo});

  final String texto;
  final String nombre;
  final bool tipo;

  List<Widget> mensajeAgente(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          maxRadius: 25,
          backgroundImage: AssetImage('assets/agente.png'),
        ),
      ),
      new Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.green,
              ),
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(
                texto,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> mensajeUsuario(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(this.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.orangeAccent,
              ),
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(
                texto,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          maxRadius: 25,
          backgroundImage: AssetImage('assets/usuario.png'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.tipo ? mensajeUsuario(context) : mensajeAgente(context),
      ),
    );
  }
}

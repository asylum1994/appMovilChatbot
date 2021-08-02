'use strict';
 
const functions = require('firebase-functions');
const {WebhookClient} = require('dialogflow-fulfillment');
const {Card, Suggestion} = require('dialogflow-fulfillment');

// iniciar conexion con la base de datos
const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    databaseURL:'ws://do-parcial-is2-default-rtdb.firebaseio.com/',
});

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

exports.dialogflowFirebaseFulfillment = functions.https.onRequest((request, response) => {
  const agent = new WebhookClient({ request, response });
  console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
  console.log('Dialogflow Request body: ' + JSON.stringify(request.body));
 
  function guardarCita(agent){
  const nombreParam =agent.parameters.nombre;
  const telefonoParam=agent.parameters.telefono; 
  const turnoParam= agent.parameters.turno; 
  
  agent.add('sus datos fueron procesados correctamente : '+nombreParam);
    
  return admin.database().ref('/persona').push({nombre:nombreParam,telefono:telefonoParam,turno:turnoParam}).then((snapshot)=>{
   console.log('se grabo exitosamente los datos : '+snapshot.ref.toString());
  });  
  }
  
  function pruebaIntent(agent){
   const nombre = agent.parameters.nombre; 
   agent.add('hola '+nombre.name+ ' yo soy una prueba');
  }
    
  
  let intentMap = new Map();  
  intentMap.set('consulta_reservar_cita',guardarCita);
  intentMap.set('prueba',pruebaIntent);
  agent.handleRequest(intentMap);
});


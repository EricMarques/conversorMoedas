import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=d76b6130";

void main() async {
  runApp(MaterialApp(
    title: "Conversor de Moedas",
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = ((dollar * this.dollar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = ((euro * this.euro) / dollar).toStringAsFixed(2);
  }

  double dollar;
  double euro;

  void _resetFields() {
    realController.clear();
    dollarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        centerTitle: true,
        backgroundColor: Colors.amber[300],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _resetFields();
            },
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados!",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados!",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 130,
                        color: Colors.amber[300],
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController moneyController, Function changed) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: moneyController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: changed,
  );
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.blueGrey, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController itemAdd = new TextEditingController();
  List _toDoList = [];

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addList() {
    setState(() {
      Map<String, dynamic> newItem = Map();
      newItem["title"] = itemAdd.text;
      newItem["OK"] = false;
      itemAdd.text = "";
      _toDoList.add(newItem);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["OK"] && !b["OK"]) return 1;
        if (!a["OK"] && b["OK"])
          return 1;
        else
          return 0;
      });
      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Lista de Tarfeas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              padding: EdgeInsetsDirectional.fromSTEB(10.0, 1.0, 10.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: itemAdd,
                      decoration: InputDecoration(
                        labelText: "Teste",
                        labelStyle: TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.lightBlue,
                    child: Text("Add"),
                    textColor: Colors.white,
                    onPressed: () {
                      _addList();
                    },
                  )
                ],
              )),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
              itemCount: _toDoList.length,
              itemBuilder: buildItem,
            ),
          ))
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecond.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.1),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direcao) {
        final snack = SnackBar(
          content: Text("Deseja Remover '" + _toDoList[index]["title"] + "' ?"),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.lightBlue,
          action: SnackBarAction(
            label: "Sim",
            textColor: Colors.white,
            onPressed: () {
              _toDoList.removeAt(index);
              _saveData();
              _refresh();
            },
          ),
        );

        Scaffold.of(context).showSnackBar(snack);
        _refresh();
      },
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["OK"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["OK"] ? Icons.check : Icons.error),
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["OK"] = c;
            _saveData();
          });
        },
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print(e);
      return null;
    }
  }
}

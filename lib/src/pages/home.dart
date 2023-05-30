import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/src/pages/models/band.dart';

class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Coldplay', votes: 10),
    Band(id: '2', name: 'Red Hot Chilli Pappers', votes: 3),
    Band(id: '3', name: 'ErosSmith', votes: 7),
    Band(id: '4', name: 'Nirvana', votes: 5),
    Band(id: '5', name: 'Bon Jovi', votes: 2)
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add, size: 25),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
       onDismissed: (direction) {
       print('diretion: $direction' 'id: ${band.id}');
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.purple[700],
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),)
        ),
      ),

    child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(band.name.substring(0, 2)),
            ),
            title: Text(band.name, style: const TextStyle(color: Colors.black87)),
            trailing: Text('${band.votes}', style: const TextStyle( fontSize: 20)),
            onTap: () {
              print(band.name);
            },
          ),
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if(!Platform.isAndroid){
      showDialog(
        context: context, 
        builder: ( context ) {
          return AlertDialog(
            title: const Text('New band name: '),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Add'),
              )
            ],
          );
        }
      );
    }

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) {
          return CupertinoAlertDialog(
            title: const Text('New band name: '),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ]
          );
        }
      );
  
  }

  void addBandToList( String name){
    
    if (name.length > 1){

      bands.add( Band(id: DateTime.now().toString(), name: name, votes: 3));
      setState(() {
        
      });

    }

    Navigator.pop(context);

  }
}
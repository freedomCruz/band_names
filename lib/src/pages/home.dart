import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';
import 'package:band_names/src/pages/models/band.dart';

class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];
  List<Color> colorList = [];
  
  Color generateRandomColor() {
     
      return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.7);
  }

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('Active-Bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload) {
    
      bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();
   

    setState(() {

    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('Active-Bands');
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
          print(socketService.serverStatus);

    return  Scaffold(
      appBar: AppBar(
        title: const Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online) 
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add, size: 25),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
       onDismissed: ( _ ) => socketService.socket.emit('delete-band', {'id': band.id}),
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

              socketService.socket.emit('vote-band', {'id': band.id });
              setState(() {});
              
            },
          ),
         
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if(!Platform.isAndroid){
      showDialog(
        context: context, 
        builder: ( _ ) => AlertDialog(
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
        )
      );
    }

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
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
        )
      );
  
  }

  void addBandToList( String name){
    
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1){
      socketService.socket.emit('add-band', {'name': name});

      final newColor = generateRandomColor();
      colorList.add(newColor);

      setState(() {
        
      });
    }

    Navigator.pop(context);

  }

  //Lista dinámica de colores


  //Mostrar gráfica

  Widget _showGraph() {

    
    Map<String, double> dataMap = new Map();
    
    for (var band in bands) {
     dataMap.putIfAbsent(band.name, () => band.votes.toDouble()); 
      
      if (bands.length > colorList.length) {
        // Se agregó una nueva banda, generar un nuevo color y agregarlo a la lista
        final newColor = generateRandomColor();
        colorList.add(newColor);
      }
    }
    

    setState(() {});

    return dataMap.isNotEmpty
    ? Container(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      width: double.infinity,
      height: 250,
      child: pieChart(dataMap)
    )
    : const Dialog(
      child: Text('Ingrese una nueva banda'),
    );

    
  }
  


  
  PieChart pieChart(Map<String, double> dataMap) => 
    
  PieChart(
    
     dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      // chartLegendSpacing: 0,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 15,
      centerText: "BANDS",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        // legendShape: _BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: false,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
  );

  
  
}


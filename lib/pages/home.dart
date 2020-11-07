import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:bandnamesapp/models/band.dart';
import 'package:bandnamesapp/services/socket_service.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() { 
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload){
    this.bands = (payload as List).map( (band) => Band.fromMap(band) ).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Band Names", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey[300],
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only( right: 10),
            child: (socketService.serverStatus == ServerStatus.Online) ? 
              Icon( Icons.check_circle, color: Colors.blue[300] ) : 
              Icon( Icons.offline_bolt, color: Colors.red[300],)
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i])
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewBand,
        elevation: 1,

      ),
   );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
          key: Key(band.id),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: EdgeInsets.only(left: 7.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Delete Band', style: TextStyle( color: Colors.white),),
            ),
            color: Colors.red,),
          onDismissed: ( _ ) => socketService.socket.emit('delete-band', {'id': band.id}),

          child: ListTile(
            leading: CircleAvatar(
              child: Text( band.name.substring(0,2)),
              backgroundColor: Colors.blue[200],
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: TextStyle( fontSize: 20),),

            onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
          ),
    );
        
  }

  addNewBand(){

    final textController = new TextEditingController();

    if ( Platform.isAndroid){
      showDialog(
        context: context,
        //Cuando tenemos un builder normalmente hay que hacer return de algun widget
        builder: ( _ ) => AlertDialog(
          title: Text("New Band Name"),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text )
            )
          ],
      )
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: ( _ ) => CupertinoAlertDialog(
          title: Text('New Band'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
      );
    }
    
  }

  void addBandToList( String name){
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1){
      
      socketService.socket.emit('add-band', { 'name': name });
      
    }


    //Esto cierra el menu
    Navigator.pop(context);

  }

  Widget _showGraph(){

    Map<String, double> dataMap = {};

    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble() );
    });

    final List<Color> colorList =[
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];

    return Container(
      height: 300,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 1,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        centerText: "BANDS",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
        ),
      ),
    );
  }


}
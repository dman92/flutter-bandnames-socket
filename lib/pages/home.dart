import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bandnamesapp/models/band.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metalica',   votes: 1),
    Band(id: '2', name: 'Mago de Oz', votes: 4),
    Band(id: '3', name: 'Debler',     votes: 9),
    Band(id: '4', name: 'Saratoga',   votes: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Band Names", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.pinkAccent,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewBand,
        elevation: 1,

      ),
   );
  }

  Widget _bandTile(Band band) {
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
          onDismissed: ( direction ){
            print('id: ${band.id}');
            //ToDo: Se deberá llamar al backend para borrarlo
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Text( band.name.substring(0,2)),
              backgroundColor: Colors.blue[200],
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: TextStyle( fontSize: 20),),
            onTap: () => print(band.name),
          ),
    );
        
  }

  addNewBand(){

    final textController = new TextEditingController();

    if ( Platform.isAndroid){
      showDialog(
        context: context,
        //Cuando tenemos un builder normalmente hay que hacer return de algun widget
        builder: ( context ) {
          return AlertDialog(
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
          );
        }
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: ( _ ) {
          return CupertinoAlertDialog(
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
          );
        }
      );
    }
    
  }

  void addBandToList( String name){

    if (name.length > 1){
      //Podemos añadir
      this.bands.add( new Band(id: DateTime.now().toString(), name: name, votes: 0 ));
      setState(() {});
    }


    //Esto cierra el menu
    Navigator.pop(context);

  }


}
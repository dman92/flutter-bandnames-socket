import 'package:flutter/cupertino.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;



enum ServerStatus{
  Online,
  Offline,
  Connecting,
}

// Change notifier: Decirle a provider que se debe refrescar el ui o notificar a todos los usuarios
class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;
  
  SocketService(){
    this._initConfig();
  }

  void _initConfig(){

    this._socket = IO.io('http://192.168.1.158:3000/', {
      'transports' : ['websocket'],
      'autoConnect': true,
    });

    this._socket.on('connect', (_) {
     this._serverStatus = ServerStatus.Online;
     notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

  }

}
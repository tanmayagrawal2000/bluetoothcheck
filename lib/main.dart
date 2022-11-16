import 'dart:async';
import 'dart:io' show Platform;
import 'package:location/location.dart';
// import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  return runApp(
    const MaterialApp(home: HomePage()),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  DiscoveredDevice? _founddevice;
  final flutterReactiveBle = FlutterReactiveBle();
  var result ='';
  @override
  void initState() {
    result='';
    super.initState();
  }
  Uuid serviceId =Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  Uuid characteristicUuid = Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
            ElevatedButton(
              child: Text('Search'),
              onPressed: (){
                requestpermission;
                setState(() {
                  result = getdevices();
                });
              },
            ),

            ElevatedButton(
              child: Text('Device Id'),
              onPressed: (){
                setState(() {
                  printdevice();
                });
              },
            ),

            ElevatedButton(
              child: Text('Connection Status'),
              onPressed: (){
                setState(() {
                  getdatafromdevice();
                  // getconnectionstatus();
                });
              },
            ),

            ElevatedButton(
              child: Text('Get Response'),
              onPressed: (){
                setState(() {
                  getresponse();
                  // getconnectionstatus();
                });
              },
            ),
            Container(
              padding: EdgeInsets.only(top: 30),
              child: Text(result),
            )
          ]
          ),
        ));
    throw UnimplementedError();
  }
// Some state management stuff
  Future<void> requestpermission()async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

  }
  void refreshScreen() {
    setState(() {});
  }
  String getdevices() {
    // final flutterReactiveBle = FlutterReactiveBle();
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if(device.name!='')
      print(device.name);
      // My BLE Tester
      //-----
      if(device.name == 'realme C21') {
        _founddevice = device;
      }
    }, onError: (Object err) {
      print('error is $err');
    });
    return 'Searched';
  }
  void printdevice(){
    print(_founddevice!.id);
    print(_founddevice!.name);
    print(_founddevice!.serviceUuids);
    print(_founddevice!.serviceData);
    result = 'ID : ${_founddevice!.id} \n Name : ${_founddevice!.name} \n ServiceUuid : ${_founddevice!.serviceUuids}';
  }

  void getdatafromdevice(){

    print('Get data from device');
    flutterReactiveBle.connectToDevice(
      id: _founddevice!.id,
      servicesWithCharacteristicsToDiscover: {serviceId: []},
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {

      if(connectionState.connectionState == DeviceConnectionState.connected){
        print('CONNECTED');
        result = 'Connected';
      }
      else if(connectionState.connectionState == DeviceConnectionState.connecting){
        print('CONNECTING');
        result = 'Connecting';
      }
      else if(connectionState.connectionState == DeviceConnectionState.disconnected){
        print('DISCONNECTED');
        result = 'Disconnected';
      }
      else if(connectionState.connectionState == DeviceConnectionState.disconnecting){
        print('DISCONNECTING');
        result = 'Disconnecting';
      }

    }, onError: (Object error) {
      print(error);
    });
  }

  void getconnectionstatus(){
    print('checking');
    flutterReactiveBle.connectToAdvertisingDevice(
      id: _founddevice!.id,
      withServices: _founddevice!.serviceUuids,
      prescanDuration: const Duration(seconds: 5),
      // servicesWithCharacteristicsToDiscover: {serviceId: []},
      connectionTimeout: const Duration(seconds:  2),
    ).listen((connectionState) {
      if(connectionState.connectionState == DeviceConnectionState.connected){
        print('CONNECTED');
        result = 'Connected';
      }
      else if(connectionState.connectionState == DeviceConnectionState.connecting){
        print('Connecting');
        result = 'Connecting';
      }
    }, onError: (dynamic error) {
      print(error);
      result = error.toString();
    });
  }

  Future<void> getresponse() async{
    Uuid cc = Uuid.parse('00009800-0000-1000-8000-00805f9b34fb');
    final characteristic = QualifiedCharacteristic(serviceId: _founddevice!.serviceUuids[0], deviceId: _founddevice!.id, characteristicId: _founddevice!.serviceUuids[0]);
    final response = await flutterReactiveBle.readCharacteristic(characteristic);
    print(response);
  }
}

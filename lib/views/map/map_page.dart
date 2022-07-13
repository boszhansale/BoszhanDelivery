import 'dart:async';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  bool justBool = true;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(43.374555, 76.930951),
    zoom: 14.4756,
  );

  static const CameraPosition _goingCameraPosition = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(43.374555, 76.930951),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414
  );

  static const marker1 =  Marker(
    markerId: MarkerId('id-1'),
    position: LatLng(43.374555, 76.930951),
    infoWindow: InfoWindow(title: "Первомайские деликатесы!")
  );

  final Set<Marker> _markers = {marker1};

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: buildAppBar('Просмотр заказа')
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
          _onMapCreated(controller);
        },
        markers: _markers
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('Go to!'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _mapController.future;
    justBool ? controller.animateCamera(CameraUpdate.newCameraPosition(_goingCameraPosition))
        : controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
    justBool = !justBool;
  }

  void _onMapCreated(GoogleMapController controller){
    setState(() {
      // _markers.add(
      //   marker1,
      // );
    });
  }
}
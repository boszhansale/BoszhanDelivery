import 'dart:async';

import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class OrderMapPage extends StatefulWidget {
  OrderMapPage(this.order);
  final Order order;

  @override
  State<OrderMapPage> createState() => OrderMapPageState();
}

class OrderMapPageState extends State<OrderMapPage> {
  GlobalKey mapKey = GlobalKey();
  final List<DrivingSessionResult> results = [];
  late Future<DrivingSessionResult> result;
  late DrivingSession session;
  late YandexMapController controller;
  double currentLat = 43.374555;
  double currentLng = 76.930951;

  final List<MapObject> mapObjects = [];
  List<PlacemarkMapObject> placeMarkers = [];
  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 2.0);

  int level = 0;
  Color trafficColor = Colors.white;

  late Timer _timer;
  int _start = 2;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            initMapSettings();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Color _colorFromTraffic(TrafficColor trafficColor) {
    switch (trafficColor) {
      case TrafficColor.red:
        return Colors.red;
      case TrafficColor.yellow:
        return Colors.yellow;
      case TrafficColor.green:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      var startPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('start_placemark'),
        point: Point(
            latitude: double.parse(widget.order.storeLat),
            longitude: double.parse(widget.order.storeLng)),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image:
                BitmapDescriptor.fromAssetImage('assets/icons/route_start.png'),
            scale: 0.4)),
      );

      var myLocPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('my_loc_placemark'),
        point:
            Point(latitude: position.latitude, longitude: position.longitude),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/icons/user.png'),
            scale: 0.6)),
      );
      mapObjects.add(myLocPlacemark);
      placeMarkers.add(myLocPlacemark);

      mapObjects.add(startPlacemark);
      placeMarkers.add(startPlacemark);
    });
  }

  void initMapSettings() async {
    await controller.toggleTrafficLayer(visible: true);

    final newBounds = BoundingBox(
      northEast: placeMarkers[0].point,
      southWest: placeMarkers[1].point,
    );
    await controller.moveCamera(
        CameraUpdate.newTiltAzimuthBounds(newBounds, azimuth: 1, tilt: 1),
        animation: animation);
    await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
    await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: placeMarkers[1].point.latitude,
              longitude: placeMarkers[1].point.longitude,
            ),
          ),
        ),
        animation: animation);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), child: buildAppBar('Карта')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 60,
        child: YandexMap(
          mapObjects: mapObjects,
          key: mapKey,
          onUserLocationAdded: (UserLocationView view) async {
            return view.copyWith(
                pin: view.pin.copyWith(
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                          'assets/icons/user.png'),
                      scale: 0.4,
                    ),
                  ),
                ),
                accuracyCircle: view.accuracyCircle
                    .copyWith(fillColor: Colors.green.withOpacity(0.5)));
          },
          onTrafficChanged: (TrafficLevel? trafficLevel) {
            setState(() {
              level = trafficLevel?.level ?? 0;
              trafficColor = trafficLevel != null
                  ? _colorFromTraffic(trafficLevel.color)
                  : Colors.white;
            });
          },
          onMapCreated: (YandexMapController yandexMapController) async {
            controller = yandexMapController;
          },
          onCameraPositionChanged: (CameraPosition cameraPosition,
              CameraUpdateReason reason, bool finished) {
            if (finished) {
              print('Camera position movement has been finished');
            }
          },
        ),
      ),
    );
  }
}

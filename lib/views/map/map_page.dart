import 'dart:async';
import 'dart:math';

import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapPage extends StatefulWidget {
  MapPage(this.lat, this.lng);
  final double lat;
  final double lng;

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
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

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      var startPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('start_placemark'),
        point:
            Point(latitude: position.latitude, longitude: position.longitude),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image:
                BitmapDescriptor.fromAssetImage('assets/icons/route_start.png'),
            scale: 0.4)),
      );

      var endPlacemark = PlacemarkMapObject(
          mapId: const MapObjectId('end_placemark'),
          point: Point(latitude: widget.lat, longitude: widget.lng),
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image:
                  BitmapDescriptor.fromAssetImage('assets/icons/route_end.png'),
              scale: 0.4)));

      mapObjects.add(startPlacemark);
      mapObjects.add(endPlacemark);
      placeMarkers.add(startPlacemark);
      placeMarkers.add(endPlacemark);

      _requestRoutes();
      _init();
    });

    final newBounds = BoundingBox(
      northEast: placeMarkers[0].point,
      southWest: placeMarkers[1].point,
    );
    await controller.moveCamera(
        CameraUpdate.newTiltAzimuthBounds(newBounds, azimuth: 1, tilt: 1),
        animation: animation);
    await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);

    // await controller.moveCamera(
    //     CameraUpdate.newCameraPosition(CameraPosition(
    //         target: Point(latitude: widget.lat, longitude: widget.lng))),
    //     animation: animation);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    _close();
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
          onMapCreated: (YandexMapController yandexMapController) async {
            controller = yandexMapController;

            final cameraPosition = await controller.getCameraPosition();
            final minZoom = await controller.getMinZoom();
            final maxZoom = await controller.getMaxZoom();

            print('Camera position: $cameraPosition');
            print('Min zoom: $minZoom, Max zoom: $maxZoom');
          },
          onCameraPositionChanged: (CameraPosition cameraPosition,
              CameraUpdateReason reason, bool finished) {
            print('Camera position: $cameraPosition, Reason: $reason');

            if (finished) {
              print('Camera position movement has been finished');
            }
          },
        ),
      ),
    );
  }

  Future<void> _requestRoutes() async {
    if (mapObjects.length > 1) {
      print('Points: ${placeMarkers[0].point},${placeMarkers[1].point}');

      var resultWithSession = YandexDriving.requestRoutes(
          points: [
            RequestPoint(
                point: placeMarkers[0].point,
                requestPointType: RequestPointType.wayPoint),
            RequestPoint(
                point: placeMarkers[1].point,
                requestPointType: RequestPointType.wayPoint),
          ],
          drivingOptions: const DrivingOptions(
              initialAzimuth: 0, routesCount: 5, avoidTolls: true));

      setState(() {
        session = resultWithSession.session;
        result = resultWithSession.result;
      });
    }
  }

  Future<void> _close() async {
    await session.close();
  }

  Future<void> _init() async {
    await _handleResult(await result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    if (result.error != null) {
      print('Error: ${result.error}');
      return;
    }

    setState(() {
      results.add(result);
    });
    setState(() {
      // result.routes!.asMap().forEach((i, route) {
      //   mapObjects.add(PolylineMapObject(
      //     mapId: MapObjectId('route_${i}_polyline'),
      //     polyline: Polyline(points: route.geometry),
      //     strokeColor:
      //         Colors.primaries[Random().nextInt(Colors.primaries.length)],
      //     strokeWidth: 3,
      //   ));
      // });

      mapObjects.add(PolylineMapObject(
        mapId: MapObjectId('route_0_polyline'),
        polyline: Polyline(points: result.routes!.first.geometry),
        strokeColor:
            Colors.primaries[Random().nextInt(Colors.primaries.length)],
        strokeWidth: 3,
      ));
    });
  }
}

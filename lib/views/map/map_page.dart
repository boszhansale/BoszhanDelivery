import 'dart:async';

import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapPage extends StatefulWidget {
  MapPage(this.orders);
  final List<Order> orders;

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
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

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //accuracy of the location data
    distanceFilter: 1, //minimum distance (measured in meters) a
    //device must move horizontally before an update event is generated;
  );

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

      var myLocPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('my_loc_placemark'),
        point:
            Point(latitude: position.latitude, longitude: position.longitude),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/icons/user.png'),
            scale: 0.6)),
      );
      mapObjects.add(myLocPlacemark);

      mapObjects.add(startPlacemark);
      placeMarkers.add(startPlacemark);

      for (int i = 0; i < widget.orders.length; i++) {
        var endPlacemark = PlacemarkMapObject(
            mapId: MapObjectId('end_placemark_$i'),
            point: Point(
                latitude: double.parse(widget.orders[i].storeLat),
                longitude: double.parse(widget.orders[i].storeLng)),
            icon: PlacemarkIcon.single(PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/route_end.png'),
                scale: 0.4)));

        mapObjects.add(endPlacemark);
        placeMarkers.add(endPlacemark);
      }

      _requestRoutes();
      _init();
    });
  }

  void locationDidChanged() async {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      setState(() {
        mapObjects.removeAt(1);
        var myLocPlacemark = PlacemarkMapObject(
          mapId: const MapObjectId('my_loc_placemark'),
          point:
              Point(latitude: position.latitude, longitude: position.longitude),
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/icons/user.png'),
              scale: 0.6)),
        );
        mapObjects.insert(1, myLocPlacemark);
      });

      await controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
              tilt: 45,
              zoom: 20,
            ),
          ),
          animation: animation);
    });
  }

  void initMapSettings() async {
    await controller.toggleTrafficLayer(visible: true);

    final newBounds = BoundingBox(
      northEast: placeMarkers[0].point,
      southWest: placeMarkers[placeMarkers.length - 1].point,
    );
    await controller.moveCamera(
        CameraUpdate.newTiltAzimuthBounds(newBounds, azimuth: 1, tilt: 1),
        animation: animation);
    await controller.moveCamera(CameraUpdate.zoomOut(), animation: animation);
    await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: placeMarkers[0].point.latitude,
              longitude: placeMarkers[0].point.longitude,
            ),
          ),
        ),
        animation: animation);

    // final mediaQuery = MediaQuery.of(context);
    // final height =
    //     mapKey.currentContext!.size!.height * mediaQuery.devicePixelRatio;
    // final width =
    //     mapKey.currentContext!.size!.width * mediaQuery.devicePixelRatio;
    //
    // await controller.toggleUserLayer(
    //   visible: true,
    //   autoZoomEnabled: true,
    //   anchor: UserLocationAnchor(
    //     normal: Offset(0.6 * height, 0.4 * width),
    //     course: Offset(0.4 * height, 0.2 * width),
    //   ),
    // );
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    locationDidChanged();
    startTimer();
  }

  @override
  void dispose() {
    _close();
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
                // arrow: view.arrow.copyWith(
                //   icon: PlacemarkIcon.single(
                //     PlacemarkIconStyle(
                //       image: BitmapDescriptor.fromAssetImage(
                //           'assets/icons/arrow.png'),
                //       scale: 0.4,
                //     ),
                //   ),
                // ),
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
      var resultWithSession = YandexDriving.requestRoutes(
          points: [
            for (int i = 0; i < placeMarkers.length; i++)
              RequestPoint(
                  point: placeMarkers[i].point,
                  requestPointType: RequestPointType.wayPoint),
          ],
          drivingOptions: const DrivingOptions(
              initialAzimuth: 0, routesCount: 1, avoidTolls: true));

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
      result.routes!.asMap().forEach((i, route) {
        mapObjects.add(PolylineMapObject(
          mapId: MapObjectId('route_${i}_polyline'),
          polyline: Polyline(points: route.geometry),
          strokeColor: Colors.blue,
          strokeWidth: 3,
        ));
      });

      // mapObjects.add(PolylineMapObject(
      //   mapId: MapObjectId('route_0_polyline'),
      //   polyline: Polyline(points: result.routes!.first.geometry),
      //   strokeColor:
      //       Colors.primaries[Random().nextInt(Colors.primaries.length)],
      //   strokeWidth: 3,
      // ));
    });
  }
}

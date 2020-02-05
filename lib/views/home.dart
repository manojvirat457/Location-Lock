import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location _location = new Location();
  LatLng latLng;
  Completer<GoogleMapController> _completer = Completer();
  CameraPosition _cameraPosition;
  GoogleMapController _controller;
  final Set<Polyline> polyline = {};
  Set<Marker> _marker = new Set();
  List<LatLng> _routeCoords;
  GoogleMapPolyline _googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyAXrIls2LEEWEZJsQFKyRaZR3SAtgq3iTk");
  LatLng _savedLatLng;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _startLocationListener();
    _mergeWithState();
    _getRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Lock'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: _cameraPosition != null ? _bodyStack() : _onLoading(),
      ),
    );
  }

  Widget _onLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        new CircularProgressIndicator(),
        new Text("Fetching Location"),
      ],
    );
  }

  Widget _bodyStack() {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: _getGoogleMap(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 10,
            right: 10,
            child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isLocked = !_isLocked;
                  });
                },
                child: _getIcon(),
                ),
          )
//          Positioned(
//            bottom: 0,
//            left: 0,
//            right: 0,
//            child: Card(
//              elevation: 10,
//              child: Container(
//                height: MediaQuery.of(context).size.height / 6,
//              ),
//            ),
//          )
        ],
      ),
    );
  }

  _getIcon() {
    if (_isLocked) {
      return Icon(Icons.lock);
    }
    return Icon(Icons.lock_open);
  }

  Widget _getGoogleMap() {
    return GoogleMap(
      mapToolbarEnabled: true,
      buildingsEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: _cameraPosition,
      markers: _marker,
      polylines: polyline,
      onMapCreated: _createMap,
      onTap: _handleClick,
    );
  }

  _handleClick(LatLng point) {
    if (!_isLocked) {
      _savedLatLng = point;
      setState(() {

      });
      _saveLocation(_savedLatLng);
      _addMarker();
    }
  }

  _startLocationListener() async {
    _location.onLocationChanged().listen((LocationData locationData) {
      _cameraPosition = CameraPosition(
          tilt: 20, target: _locationDataToLatLng(locationData), zoom: 16);
      latLng = _locationDataToLatLng(locationData);
      _addMarker();
    });
  }

  _addMarker() {
    if (_savedLatLng.latitude != 0.0 && _savedLatLng != null) {
      var marker1 = new Marker(
          markerId: MarkerId("2"),
          position: _savedLatLng,
          infoWindow: InfoWindow(
            title: 'Destination',
          ),
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet));
      _marker.add(marker1);
    }

    setState(() {});
  }

  _getRoute() async {
    _routeCoords = await _googleMapPolyline.getCoordinatesWithLocation(
        origin: latLng,
        destination: LatLng(11.039708, 76.750970),
        mode: RouteMode.driving);
  }

  _locationDataToLatLng(LocationData locationData) {
    return new LatLng(locationData.latitude, locationData.longitude);
  }

  void _createMap(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      polyline.add(Polyline(
          polylineId: PolylineId("1"),
          visible: true,
          points: _routeCoords,
          width: 4,
          color: Colors.deepOrange,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });

    _completer.complete(controller);
  }

  void _saveLocation(LatLng latLng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', latLng.latitude);
    prefs.setDouble('longitude', latLng.longitude);
  }

  _getSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return new LatLng(
        prefs.getInt('latitude') ?? 0, prefs.getInt('longitude') ?? 0);
  }

  _mergeWithState() async {
    _savedLatLng = await _getSavedLocation();
    setState(() {});
    print("______________________________________________");
    print(_savedLatLng.latitude);
    print("______________________________________________");
  }
}

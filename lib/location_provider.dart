import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

GeolocatorPlatform _geo = PresenceGeo();

class PresenceGeo extends GeolocatorPlatform {}

class LocationProvider with ChangeNotifier {
  BitmapDescriptor? _pinLocationIcon;
  BitmapDescriptor? get pinLocationIcon => _pinLocationIcon;
  Map<MarkerId, Marker>? _marker;
  Map<MarkerId, Marker>? get marker => _marker;
  final MarkerId markerId = const MarkerId("1");

  PermissionStatus? _permissionStatus;
  PermissionStatus? get permissionStatus => _permissionStatus;

  final Location _location = Location();
  Location get location => _location;
  LatLng? _locationPosition;
  LatLng? get locationPosition => _locationPosition;

  late StreamSubscription<LocationData> _locationSubscription;

  bool _inRadius = false;
  bool get inRadius => _inRadius;

  late double maxRadius;
  late double latOffice;
  late double longOffice;

  initialization(double latOffice, double longOffice, double maxRadius) async {
    this.latOffice = latOffice;
    this.longOffice = longOffice;
    this.maxRadius = maxRadius;
    await _getUserLocation();
    await _setCustomMapPin();
  }

  close() {
    _locationSubscription.cancel();
  }

  _getUserLocation() async {
    bool _serviceEnable;

    _serviceEnable = await _location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await _location.requestService();

      if (!_serviceEnable) {
        return;
      }
    }

    _permissionStatus = await _location.hasPermission();
    notifyListeners();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();

      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      ///change user location
      _locationPosition =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      ///check Radius
      _checkRadius(latOffice, longOffice, _locationPosition!.latitude,
          _locationPosition!.longitude, maxRadius);

      ///init Marker
      _marker = <MarkerId, Marker>{};
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(latOffice, longOffice),
        icon: pinLocationIcon ?? BitmapDescriptor.defaultMarker,
      );

      _marker![markerId] = marker;
      notifyListeners();
    });
  }

  _setCustomMapPin() async {
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/icon_office_location.png',
    );
  }

  _checkRadius(double latOffice, double longOffice, double currentLat,
      double currentLong, double defaultRadiusOffice) {
    final double distance = _geo.distanceBetween(
      latOffice,
      longOffice,
      currentLat,
      currentLong,
    );

    _inRadius = distance < defaultRadiusOffice;
    notifyListeners();
  }
}

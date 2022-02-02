import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:realtime_location_providers/location_provider.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late LocationProvider locProv;

  // local office location
  double latOffice = -6.2398;
  double longOffice = 107.0085;
  double radius = 100;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context
        .read<LocationProvider>()
        .initialization(latOffice, longOffice, radius));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locProv = Provider.of<LocationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    // close stream
    locProv.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Page'),
      ),
      body: Column(
        children: [
          GestureDetector(
            child: Container(
              height: 336,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  if (locationProvider.locationPosition != null) {
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: locationProvider.locationPosition!,
                          zoom: 15.5),
                      mapType: MapType.normal,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: Set<Marker>.of(locationProvider.marker!.values),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer()),
                        Factory<PanGestureRecognizer>(
                            () => PanGestureRecognizer()),
                        Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer()),
                        Factory<TapGestureRecognizer>(
                            () => TapGestureRecognizer()),
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer())
                      },
                      circles: {
                        Circle(
                          circleId: const CircleId('office_circle'),
                          center: LatLng(latOffice, longOffice),
                          radius: radius,
                          fillColor: Colors.green.shade100.withOpacity(0.5),
                          strokeColor: Colors.green.shade200.withOpacity(0.8),
                          strokeWidth: 4,
                        ),
                      },
                    );
                  } else if (locationProvider.permissionStatus !=
                      PermissionStatus.granted) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/image_permissions.png',
                            height: 100,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'Uppss. Permission Lokasi anda belum aktif.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Izinkan aplikasi mengakses lokasi anda agar dapat melakukan presensi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Consumer<LocationProvider>(builder: (context, provider, _) {
            if (provider.locationPosition != null) {
              return Text(
                  'LAT : ${locProv.locationPosition!.latitude}. LONG : ${locProv.locationPosition!.longitude}');
            } else {
              return const Text('-');
            }
          }),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MapDemoApp());
}

class MapDemoApp extends StatelessWidget {
  const MapDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Demo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ---------------------------------------------------------------------------
  // STEP 2: INITIAL CAMERA POSITION
  // ---------------------------------------------------------------------------

  // Example starting location: Mumbai.
  // Replace this with your city/campus coordinates.
  static const LatLng _initialLocation = LatLng(
    19.0760,
    72.8777,
  );

  static const double _initialZoom = 12.0;
  static const double _userZoom = 16.0;

  // ---------------------------------------------------------------------------
  // MAP STATE
  // ---------------------------------------------------------------------------

  GoogleMapController? _mapController;

  LatLng? _currentLocation;

  bool _isLoadingLocation = true;
  bool _isFollowingUser = false;

  String? _locationError;

  StreamSubscription<Position>? _positionSubscription;

  // ---------------------------------------------------------------------------
  // STEP 4: MARKERS
  // ---------------------------------------------------------------------------

  final Map<MarkerId, Marker> _markers = {};

  MarkerId? _selectedMarkerId;

  // Example points of interest.
  final List<Map<String, dynamic>> _places = [
    {
      'id': 'gateway_of_india',
      'title': 'Gateway of India',
      'description':
          'A famous landmark located near the waterfront in South Mumbai.',
      'latitude': 18.9220,
      'longitude': 72.8347,
    },
    {
      'id': 'marine_drive',
      'title': 'Marine Drive',
      'description':
          'A popular seaside promenade along the Arabian Sea.',
      'latitude': 18.9431,
      'longitude': 72.8235,
    },
    {
      'id': 'bandra_fort',
      'title': 'Bandra Fort',
      'description':
          'A historic fort overlooking the Arabian Sea.',
      'latitude': 19.0437,
      'longitude': 72.8194,
    },
  ];

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _createInitialMarkers();

    // Start location setup after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // STEP 4: CREATE INITIAL MARKERS
  // ---------------------------------------------------------------------------

  void _createInitialMarkers() {
    for (final place in _places) {
      final markerId = MarkerId(place['id'] as String);

      final marker = Marker(
        markerId: markerId,
        position: LatLng(
          place['latitude'] as double,
          place['longitude'] as double,
        ),
        infoWindow: InfoWindow(
          title: place['title'] as String,
          snippet: place['description'] as String,
        ),
        onTap: () {
          _selectMarker(markerId);
        },
      );

      _markers[markerId] = marker;
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 3: INITIALIZE LOCATION
  // ---------------------------------------------------------------------------

  Future<void> _initializeLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check whether location services are enabled.
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationError =
              'Location services are disabled. Please enable location services.';
        });

        return;
      }

      // Check existing permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Request permission if needed.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // User denied permission.
      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationError =
              'Location permission was denied.';
        });

        return;
      }

      // User permanently denied permission.
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationError =
              'Location permission is permanently denied. '
              'Please enable it from app settings.';
        });

        return;
      }

      // Permission granted.
      await _getCurrentLocation();

      // Start listening for location updates.
      _startLocationUpdates();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _locationError =
            'Unable to determine your current location.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 3: GET CURRENT LOCATION
  // ---------------------------------------------------------------------------

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await _updateUserLocation(position);

      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _locationError = null;
      });

      // Move the camera to the user's location.
      await _moveCameraTo(
        _currentLocation!,
        zoom: _userZoom,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _locationError =
            'Could not get your current location.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LIVE LOCATION UPDATES
  // ---------------------------------------------------------------------------

  void _startLocationUpdates() {
    _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateUserLocation(position);
      },
      onError: (error) {
        debugPrint(
          'Location stream error: $error',
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE USER LOCATION MARKER
  // ---------------------------------------------------------------------------

  Future<void> _updateUserLocation(
    Position position,
  ) async {
    final location = LatLng(
      position.latitude,
      position.longitude,
    );

    _currentLocation = location;

    final userMarkerId =
        const MarkerId('current_user');

    final userMarker = Marker(
      markerId: userMarkerId,
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ),
      infoWindow: const InfoWindow(
        title: 'You are here',
        snippet: 'Your current location',
      ),
      zIndexInt: 100,
    );

    if (!mounted) return;

    setState(() {
      _markers[userMarkerId] = userMarker;
    });

    // Keep the camera following the user only when explicitly enabled.
    if (_isFollowingUser) {
      await _moveCameraTo(
        location,
        zoom: _userZoom,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MAP CREATION
  // ---------------------------------------------------------------------------

  void _onMapCreated(
    GoogleMapController controller,
  ) {
    _mapController = controller;

    if (_currentLocation != null) {
      _moveCameraTo(
        _currentLocation!,
        zoom: _userZoom,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 5: MOVE CAMERA
  // ---------------------------------------------------------------------------

  Future<void> _moveCameraTo(
    LatLng location, {
    double zoom = _userZoom,
  }) async {
    final controller = _mapController;

    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 5: RECENTER BUTTON
  // ---------------------------------------------------------------------------

  Future<void> _recenterMap() async {
    // If we don't have a location yet, try getting it.
    if (_currentLocation == null) {
      await _initializeLocation();
      return;
    }

    setState(() {
      _isFollowingUser = true;
    });

    await _moveCameraTo(
      _currentLocation!,
      zoom: _userZoom,
    );
  }

  // ---------------------------------------------------------------------------
  // STOP FOLLOWING WHEN USER MOVES THE MAP
  // ---------------------------------------------------------------------------

  void _onCameraMoveStarted() {
    if (_isFollowingUser && mounted) {
      setState(() {
        _isFollowingUser = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 5: MARKER SELECTION
  // ---------------------------------------------------------------------------

  void _selectMarker(MarkerId markerId) {
    if (!mounted) return;

    setState(() {
      _selectedMarkerId = markerId;
    });
  }

  void _clearSelectedMarker() {
    if (!mounted) return;

    setState(() {
      _selectedMarkerId = null;
    });
  }

  // ---------------------------------------------------------------------------
  // ADD MARKER ON LONG PRESS
  // ---------------------------------------------------------------------------

  void _addMarkerAt(LatLng position) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final markerId = MarkerId(id);

    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      infoWindow: const InfoWindow(
        title: 'Custom Marker',
        snippet: 'Marker added by you',
      ),
      onTap: () {
        _selectMarker(markerId);
      },
    );

    setState(() {
      _markers[markerId] = marker;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marker added to the map'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN SETTINGS
  // ---------------------------------------------------------------------------

  Future<void> _openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  // ---------------------------------------------------------------------------
  // SELECTED MARKER DETAILS
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? get _selectedPlace {
    final markerId = _selectedMarkerId;

    if (markerId == null) return null;

    for (final place in _places) {
      if (place['id'] == markerId.value) {
        return place;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =======================================================================
      // STEP 1: TOP APP BAR
      // =======================================================================

      appBar: AppBar(
        title: const Text('Map Demo App'),
        centerTitle: true,
        elevation: 2,
      ),

      // =======================================================================
      // STEP 1: FULL-SCREEN MAP
      // =======================================================================

      body: Stack(
        children: [
          GoogleMap(
            // =================================================================
            // STEP 2: INITIAL CAMERA POSITION
            // =================================================================

            initialCameraPosition: const CameraPosition(
              target: _initialLocation,
              zoom: _initialZoom,
            ),

            // ================================================================
            // STEP 4: USER LOCATION
            // ================================================================

            myLocationEnabled: true,
            myLocationButtonEnabled: false,

            // ================================================================
            // STEP 4: ALL MARKERS
            // ================================================================

            markers: Set<Marker>.of(
              _markers.values,
            ),

            // ================================================================
            // MAP INTERACTION
            // ================================================================

            onMapCreated: _onMapCreated,

            onCameraMoveStarted:
                _onCameraMoveStarted,

            // Long press creates an additional marker.
            onLongPress: _addMarkerAt,

            // ================================================================
            // MAP SETTINGS
            // ================================================================

            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,

            // Show Google's traffic layer if desired.
            trafficEnabled: false,

            // Improve map appearance.
            buildingsEnabled: true,
            indoorViewEnabled: true,
          ),

          // =================================================================
          // LOADING INDICATOR
          // =================================================================

          if (_isLoadingLocation)
            const Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _StatusCard(
                icon: Icons.location_searching,
                message: 'Getting your current location...',
              ),
            ),

          // =================================================================
          // LOCATION ERROR
          // =================================================================

          if (!_isLoadingLocation &&
              _locationError != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _LocationErrorCard(
                message: _locationError!,
                onSettingsPressed:
                    _openLocationSettings,
                onRetryPressed:
                    _initializeLocation,
              ),
            ),

          // =================================================================
          // STEP 4/5: MARKER DETAILS PANEL
          // =================================================================

          if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _MarkerDetailsPanel(
                title:
                    _selectedPlace!['title'] as String,
                description:
                    _selectedPlace!['description']
                        as String,
                latitude:
                    _selectedPlace!['latitude']
                        as double,
                longitude:
                    _selectedPlace!['longitude']
                        as double,
                onClose: _clearSelectedMarker,
              ),
            ),
        ],
      ),

      // =======================================================================
      // STEP 1 + STEP 5: FLOATING ACTION BUTTON
      // =======================================================================

      floatingActionButton: FloatingActionButton(
        tooltip: 'Go to my current location',
        onPressed: _recenterMap,
        child: const Icon(
          Icons.my_location,
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS CARD
// =============================================================================

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOCATION ERROR CARD
// =============================================================================

class _LocationErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onSettingsPressed;
  final VoidCallback onRetryPressed;

  const _LocationErrorCard({
    required this.message,
    required this.onSettingsPressed,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPermanent =
        message.contains('permanently');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_off,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Location unavailable',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onRetryPressed,
                  child: const Text('Retry'),
                ),
                if (isPermanent)
                  FilledButton(
                    onPressed: onSettingsPressed,
                    child: const Text('Settings'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MARKER DETAILS PANEL
// =============================================================================

class _MarkerDetailsPanel extends StatelessWidget {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final VoidCallback onClose;

  const _MarkerDetailsPanel({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${latitude.toStringAsFixed(5)}, '
                    '${longitude.toStringAsFixed(5)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:carbo/languages/strings.dart';
import 'package:carbo/base/themes/token.dart';
import 'package:carbo/views/booking/model/pickup_location_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'dart:math' as math;

class LocationPickerWidget extends StatefulWidget {
  final Function(PickupLocation) onLocationSelected;
  final PickupLocation? initialLocation;
  /// Optional geofence center (lat/lng) to show an allowed area
  final LatLng? center;
  /// Optional radius for allowed area in meters
  final double? radiusMeters;

  const LocationPickerWidget({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
    this.center,
    this.radiusMeters,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  Set<Marker> _markers = {};
  Circle? _allowedCircle;
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isOutOfRange = false;
  double? _distanceToCenter;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Request location permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

        if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        if (widget.initialLocation != null) {
          _selectedLocation = LatLng(
            widget.initialLocation!.latitude,
            widget.initialLocation!.longitude,
          );
          _selectedAddress = widget.initialLocation!.address;
          _updateMarker();
        } else {
          Position? position = await Geolocator.getLastKnownPosition();
          position ??= await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          ).timeout(
            const Duration(seconds: 4),
            onTimeout: () => Position(
              latitude: 24.7136,
              longitude: 46.6753,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            ),
          );
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _selectedAddress = DynamicLanguage.key(Strings.CurrentLocation);
          _updateMarker();

          // Fetch actual address for current location
          try {
            final address = await _getAddressFromCoordinates(position.latitude, position.longitude);
            if (mounted) {
              _selectedAddress = address;
              _updateMarker();
            }
          } catch (e) {
            debugPrint('Error fetching initial address: $e');
          }
        }
      }
      else if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        // Mark permission denied so UI can show guidance
        _permissionDenied = true;
      }
    } catch (e) {
      debugPrint('Error initializing location: $e');
    } finally {
      // If we couldn't determine a location (permission denied or error), fall back to a safe default center
      if (_selectedLocation == null) {
        _selectedLocation = LatLng(24.7136, 46.6753); // Riyadh center as neutral fallback
        _selectedAddress = DynamicLanguage.key(Strings.PickUpLocation);
        _updateMarker();
      }
      setState(() => _isLoading = false);
    }
  }

  void _updateMarker() {
    if (_selectedLocation != null) {
      _markers = {
        Marker(
          markerId: MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: InfoWindow(title: _selectedAddress),
        ),
      };
      // Add center marker if provided
      if (widget.center != null) {
        _markers = _markers..add(
          Marker(
            markerId: MarkerId('center_marker'),
            position: widget.center!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: DynamicLanguage.key(Strings.Center)),
          ),
        );
      }
      // Build allowed circle if radius supplied
      if (widget.center != null && widget.radiusMeters != null) {
        _allowedCircle = Circle(
          circleId: CircleId('allowed_area'),
          center: widget.center!,
          radius: widget.radiusMeters!,
          fillColor: Colors.blue.withOpacity(0.08),
          strokeColor: Colors.blue.withOpacity(0.4),
          strokeWidth: 2,
        );
      }
    }
  }

  void _onMapTapped(LatLng position) async {
    // If center/radius provided, compute distance to center and validate
    if (widget.center != null && widget.radiusMeters != null) {
      final d = Geolocator.distanceBetween(
        widget.center!.latitude,
        widget.center!.longitude,
        position.latitude,
        position.longitude,
      );
      _distanceToCenter = d;
      _isOutOfRange = d > widget.radiusMeters!;

      if (_isOutOfRange) {
        // Clamp to nearest point on circle perimeter
        final snapped = _closestPointOnCircle(widget.center!, widget.radiusMeters!, position);
        _selectedLocation = snapped;
        _selectedAddress = DynamicLanguage.key(Strings.SnappedShort);
        _distanceToCenter = widget.radiusMeters!;
        _isOutOfRange = false; // now inside

        setState(() {
          _updateMarker();
        });

        // Fetch address for snapped location
        _getAddressFromCoordinates(snapped.latitude, snapped.longitude).then((address) {
          if (mounted) {
            setState(() {
              _selectedAddress = address;
              _updateMarker();
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(DynamicLanguage.key(Strings.SnappedOutsideAllowed)),
            duration: Duration(seconds: 3),
          ),
        );

        return;
      }
    }

    // Normal selection inside allowed area (or when no center/radius provided)
    _selectedLocation = position;
    _selectedAddress = DynamicLanguage.key(Strings.pleaseWait);
    _updateMarker();
    
    setState(() {}); // Update UI with loading state

    // Get address from coordinates asynchronously
    try {
      final address = await _getAddressFromCoordinates(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _updateMarker();
        });
      }
    } catch (e) {
      debugPrint('Error fetching address on tap: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _updateMarker();
        });
      }
    }
  }

  /// Compute the closest point on the circle perimeter to [tap]. Uses spherical formulas.
  LatLng _closestPointOnCircle(LatLng center, double radiusMeters, LatLng tap) {
    // Convert degrees to radians
    final lat1 = center.latitude * math.pi / 180.0;
    final lon1 = center.longitude * math.pi / 180.0;
    final lat2 = tap.latitude * math.pi / 180.0;
    final lon2 = tap.longitude * math.pi / 180.0;

    // angular distance between center and tap (not used directly but kept for clarity)
    final R = 6371000.0; // Earth radius in meters

    // initial bearing from center to tap
    final y = math.sin(lon2 - lon1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);
    final bearing = math.atan2(y, x);

    // angular distance for desired point = radius / R
    final angularDist = radiusMeters / R;

    // compute destination point from center using bearing and angular distance
    final lat3 = math.asin(math.sin(lat1) * math.cos(angularDist) +
        math.cos(lat1) * math.sin(angularDist) * math.cos(bearing));
    final lon3 = lon1 + math.atan2(
        math.sin(bearing) * math.sin(angularDist) * math.cos(lat1),
        math.cos(angularDist) - math.sin(lat1) * math.sin(lat3));

    return LatLng(lat3 * 180.0 / math.pi, lon3 * 180.0 / math.pi);
  }

  /// Convert latitude and longitude to human-readable address using reverse geocoding
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        // Build address string from available components
        final addressParts = <String>[];
        
        // Prioritize street, then name
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        } else if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        // Remove duplicates and join
        final uniqueParts = addressParts.toSet().toList();
        if (uniqueParts.isNotEmpty) {
          return uniqueParts.join(', ');
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    
    // Fallback to lat/lng format if geocoding fails
    final latStr = latitude.toStringAsFixed(4);
    final lngStr = longitude.toStringAsFixed(4);
    return 'Lat: $latStr, Lng: $lngStr';
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      final pickupLocation = PickupLocation(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _selectedAddress,
      );
      widget.onLocationSelected(pickupLocation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DynamicLanguage.key(Strings.PickUpLocation)),
        backgroundColor: CustomColor.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: CustomColor.primary),
            )
          : _selectedLocation == null
              ? Center(
                  child: Text(DynamicLanguage.key(Strings.PickUpLocation)),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation!,
                        zoom: 15,
                      ),
                      onTap: _onMapTapped,
                      markers: _markers,
                      circles: _allowedCircle != null ? {_allowedCircle!} : {},
                      zoomControlsEnabled: true,
                    ),
                    if (_permissionDenied)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Material(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DynamicLanguage.key(Strings.LocationPermissionDenied),
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Geolocator.openAppSettings();
                                  },
                                  child: Text(DynamicLanguage.key(Strings.OpenSettings)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DynamicLanguage.key(Strings.SelectedLocation),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _selectedAddress +
                                      (_distanceToCenter != null
                                          ? ('\n' + (() {
                                              final km = (_distanceToCenter! / 1000).toStringAsFixed(2);
                                              final local = AppLocalizations.of(context);
                                              return local != null
                                                  ? local.appLDistanceLabel(km)
                                                  : 'Distance: $km km';
                                            })())
                                          : ''),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1F2937),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isOutOfRange ? null : _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.primary,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              DynamicLanguage.key(Strings.ConfirmLocation),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

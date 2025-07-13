import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class StreetViewPage extends StatefulWidget {
  final String siteName;
  final double? latitude;
  final double? longitude;

  const StreetViewPage({
    super.key,
    required this.siteName,
    this.latitude,
    this.longitude,
  });

  @override
  State<StreetViewPage> createState() => _StreetViewPageState();
}

class _StreetViewPageState extends State<StreetViewPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  double? _siteLatitude;
  double? _siteLongitude;
  String? _userDistrict;
  double? _userLatitude;
  double? _userLongitude;

  // Your Google Maps API key (same as used in MapViewScreen)
  static const String _apiKey = 'AIzaSyCyqzryof5ULhLPpxqjtMPG22RtpOu7r3w';

  @override
  void initState() {
    super.initState();
    _initializeStreetView();
    _getUserLocation();
  }

  Future<void> _initializeStreetView() async {
    if (widget.latitude != null && widget.longitude != null) {
      _siteLatitude = widget.latitude;
      _siteLongitude = widget.longitude;
      _setupWebView();
    } else {
      await _fetchCoordinatesFromFirestore();
    }
  }

  Future<void> _fetchCoordinatesFromFirestore() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: widget.siteName.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final lat = doc['latitude'];
        final lng = doc['longitude'];

        double? latitude;
        double? longitude;

        if (lat is double && lng is double) {
          latitude = lat;
          longitude = lng;
        } else if (lat is int && lng is int) {
          latitude = lat.toDouble();
          longitude = lng.toDouble();
        } else if (lat is String && lng is String) {
          latitude = double.tryParse(lat);
          longitude = double.tryParse(lng);
        }

        if (latitude != null && longitude != null) {
          _siteLatitude = latitude;
          _siteLongitude = longitude;
          _setupWebView();
        } else {
          _setError('Invalid coordinates for this location');
        }
      } else {
        _setError('Location not found in database');
      }
    } catch (e) {
      _setError('Error fetching location: $e');
    }
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _userDistrict = "Location services disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _userDistrict = "Location permission denied";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _userDistrict = "Location permission permanently denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        _userDistrict = placemarks.isNotEmpty
            ? (placemarks.first.subAdministrativeArea ??
                placemarks.first.locality ??
                "Unknown District")
            : "District not found";
      });
    } catch (e) {
      setState(() {
        _userDistrict = "Error getting location: $e";
      });
    }
  }

  void _setupWebView() {
    if (_siteLatitude == null || _siteLongitude == null) return;

    final streetViewHtml = _generateStreetViewHtml();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            _setError('Street View failed to load: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(streetViewHtml);
  }

  String _generateStreetViewHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            html, body, #pano {
                height: 100%;
                margin: 0;
                padding: 0;
                font-family: Arial, sans-serif;
            }
            #error-message {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0, 0, 0, 0.8);
                color: white;
                padding: 20px;
                border-radius: 10px;
                text-align: center;
                z-index: 1000;
            }
            .loading {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                color: #333;
                font-size: 16px;
            }
        </style>
    </head>
    <body>
        <div id="pano"></div>
        <div id="loading" class="loading">Loading Street View...</div>
        <div id="error-message" style="display: none;"></div>
        
        <script>
            let panorama;
            let streetViewService;
            
            function initStreetView() {
                const targetLocation = { lat: $_siteLatitude, lng: $_siteLongitude };
                
                streetViewService = new google.maps.StreetViewService();
                
                streetViewService.getPanorama({
                    location: targetLocation,
                    radius: 50,
                    source: google.maps.StreetViewSource.OUTDOOR
                }, processSVData);
            }
            
            function processSVData(data, status) {
                const loading = document.getElementById('loading');
                const errorDiv = document.getElementById('error-message');
                
                if (status === 'OK') {
                    loading.style.display = 'none';
                    
                    panorama = new google.maps.StreetViewPanorama(
                        document.getElementById('pano'),
                        {
                            position: data.location.latLng,
                            pov: {
                                heading: 0,
                                pitch: 0
                            },
                            zoom: 1,
                            motionTracking: false,
                            motionTrackingControl: false,
                            addressControl: false,
                            linksControl: true,
                            panControl: true,
                            enableCloseButton: false,
                            showRoadLabels: false
                        }
                    );
                } else {
                    loading.style.display = 'none';
                    errorDiv.innerHTML = 'Street View not available for this location<br><small>Try a different location or check back later</small>';
                    errorDiv.style.display = 'block';
                }
            }
            
            window.onerror = function(msg, url, line, col, error) {
                const loading = document.getElementById('loading');
                const errorDiv = document.getElementById('error-message');
                loading.style.display = 'none';
                errorDiv.innerHTML = 'Error loading Street View<br><small>Please check your internet connection</small>';
                errorDiv.style.display = 'block';
            };
        </script>
        
        <script async defer 
            src="https://maps.googleapis.com/maps/api/js?key=$_apiKey&callback=initStreetView">
        </script>
    </body>
    </html>
    ''';
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Street View Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeStreetView();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreetViewContent() {
    if (_hasError) return _buildErrorView();
    if (_siteLatitude != null && _siteLongitude != null) {
      return WebViewWidget(controller: _webViewController);
    }
    return const SizedBox();
  }

  Widget _buildLoadingIndicator() {
    return _isLoading && !_hasError
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildStreetViewContent(),
          _buildLoadingIndicator(),
          // Segment 7: Custom AppBar with blur effect and title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Street View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.siteName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/*
*    # Use as a wrapper for NetworkAwareScaffold
*     NetworkAwareScaffold(
*        child: YourHomeScreen(),
*     )
*/

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal() {
    _initConnectivityListener();
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _internetStatusController = StreamController<bool>.broadcast();

  Stream<bool> get onInternetStatusChange => _internetStatusController.stream;

  /// Call this once at app start
  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final hasInternet = await isConnectedToInternet();
      _internetStatusController.add(hasInternet);
    });
  }

  /// Checks both network connection and real internet availability
  Future<bool> isConnectedToInternet() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('http://clients3.google.com/generate_204'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 204) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }

    return false;
  }

  /// Dispose stream controller when app exits
  void dispose() {
    _internetStatusController.close();
  }
}
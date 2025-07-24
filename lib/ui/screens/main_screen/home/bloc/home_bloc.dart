import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/models/rest_api_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  HomeBloc() : super(HomeLoadingState()) {
    on<DashboardEvent>(_getDashboardInitData);
    on<PunchLogsEvent>(_getPunchLogsInitData);
    on<PunchInOutEvent>(_punchInOut);
  }

  Future<void> _getDashboardInitData(DashboardEvent event, emit) async {
    emit(HomeLoadingState());
    try {

      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const HomeErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(HomeErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      final punchStatus = await _restApiRepository.getPunchedStatus(variables: {
        "payload":{
          "userId": auth.user!.userId
        }
      });

      await _restApiRepository.getPunchedLogs(variables: {
        "payload":{
          "fromDate": //"2025-01-02T00:00:00.000",
              DateTime.parse("${event.dateFilter} ${AppConstants.dateFixStart}")
                  .toIso8601String(),
          "toDate":
              DateTime.parse("${event.dateFilter} ${AppConstants.dateFixEnd}")
                  .toIso8601String(),
          "userId": auth.user!.userId
        }
      }).then((punchDetails) {
        // print("harshit");
        emit(HomeLoadedState(punchLogs: punchDetails, punchStatus: punchStatus));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(HomeUnAuthState(message: e.toString()));
        } else {
          emit(HomeErrorState(message: e.toString()));
        }
      });
    } catch (e) {
      if(e.toString() == RestApiRepositoryImp.errorStr){
        emit(HomeUnAuthState(message: e.toString()));
      } else {
        emit(HomeErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _getPunchLogsInitData(PunchLogsEvent event, emit) async {
    emit(HomeLoadingState());
    try {

      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const HomeErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(HomeErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      final punchStatus = await _restApiRepository.getPunchedStatus(variables: {
        "payload":{
          "userId": auth.user!.userId
        }
      });

      await _restApiRepository.getPunchedLogs(variables: {
        "payload":{
          "fromDate": //"2025-01-02T00:00:00.000",
              DateTime.parse("${event.dateFilter} ${AppConstants.dateFixStart}")
                  .toIso8601String(),
          "toDate":
              DateTime.parse("${event.dateFilter} ${AppConstants.dateFixEnd}")
                  .toIso8601String(),
          "userId": auth.user!.userId
        }
      }).then((punchDetails) {
        emit(HomeLoadedState(punchLogs: punchDetails, punchStatus: punchStatus));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(HomeUnAuthState(message: e.toString()));
        } else {
          emit(HomeErrorState(message: e.toString()));
        }
      });
    } catch (e) {
      if(e.toString() == RestApiRepositoryImp.errorStr){
        emit(HomeUnAuthState(message: e.toString()));
      } else {
        emit(HomeErrorState(message: e.toString()));
      }
    }
  }

  Future<void> _punchInOut(PunchInOutEvent event, emit) async {
    emit(HomeLoadingState());
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const HomeErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(HomeErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      final Position position = await _determinePosition();
      if (isGeoFencing(auth, position.latitude, position.longitude)) {
        final DateTime now = DateTime.now();
        final Map<String, dynamic> variables = {
          "payload": {
            "ip":"0.0.0.0",
            "ind": event.punchType.toString().split('.').last,
            "userId": auth.user!.userId,
            "attndDate": now.toIso8601String(),
            "at_Time": DateFormat('HH:mm:ss').format(now),
            "user_Altitude": position.altitude,
            "user_Latitude": position.latitude,
            "user_Longitude": position.longitude,
            // "user_Latitude": "31.070386",
            // "user_Longitude": "77.1865853",
            "source": "Mobile",
            "notes": ""
          }
        };

        await _restApiRepository.setPunchedIn(
            variables: variables).then((punchStatus) async {

          await _restApiRepository.getPunchedLogs(variables: {
            "payload": {
              "fromDate": DateTime.parse(
                      "${event.todayDate} ${AppConstants.dateFixStart}")
                  .toIso8601String(),
              "toDate": DateTime.parse(
                      "${event.todayDate} ${AppConstants.dateFixEnd}")
                  .toIso8601String(),
              "userId": auth.user!.userId
            }
          }).then((punchDetails) {
            emit(HomeLoadedState(punchLogs: punchDetails, punchStatus: punchStatus));
          }, onError: (e) {
            emit(HomeErrorState(message: e.toString()));
          });
        }, onError: (e) {
          emit(HomeErrorState(message: e.toString()));
        });
      } else {
        emit(HomeErrorState(message: R.strings.msgNotAllowedPP));
      }
    } catch (e) {
      emit(HomeErrorState(message: e.toString()));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(R.strings.msgLocationDisable);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(R.strings.msgLocationDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(R.strings.msgLocationPDenied);
    }

    print("All permission granted");
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  bool isGeoFencing(AuthResponse auth, double currentLat, double currentLong) {
    // final List<GeofenceSet> geofenceSet = auth.user?.geofenceSet ?? [];
    // final bool isGeoFenceException = auth.user?.isGeoException ?? false;
    //
    // if(geofenceSet.isEmpty || isGeoFenceException){
    //   return true;
    // }
    // for (var element in geofenceSet) {
    //   final double lat = element.coordinates.lat;
    //   final double long = element.coordinates.long;
    //   final double radius = element.coordinates.radius;
    //
    //   double distanceInMeters =
    //   Geolocator.distanceBetween(currentLat, currentLong, lat, long);
    //   /*debugPrint("GeofenceSet = $currentLat, $currentLong, :::: {$lat, $long, = radius $radius}");
    //   debugPrint("distanceInMeters = $distanceInMeters");
    //   debugPrint("radius = $radius");*/
    //   if(distanceInMeters <= radius) {
        return true;
    //   }
    // }

    // return false;
  }

// Future<void> punchOut(PunchOutEvent event, emit) async {
//   emit(HomeLoadingState());
//   try {
//     AuthResponse auth = await AuthService.instance.getCurrentUserData();
//     if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
//       AuthService.instance.clearUserData();
//       emit(const HomeErrorState(message: AppConstants.unAuthorization));
//       return Future(() => false);
//     }
//
//     final isConnected = await NetworkManager().isConnectedToInternet();
//     if (connectivityResult == ConnectivityResult.none) {
//       emit(HomeErrorState(message: R.strings.errAPINoNet));
//       return Future(() => false);
//     }
//
//     final Position position = await _determinePosition();
//     if (isGeoFencing(auth, position.latitude, position.longitude)) {
//       final DateTime now = DateTime.now();
//       final Map<String, dynamic> variables = {
//         "payload": {
//           "ip":"0.0.0.0",
//           "ind":"BtnOut",
//           "userId": auth.user!.userId,
//           "attndDate": now.toIso8601String(),
//           "at_Time": DateFormat('HH:mm:ss').format(now),
//           "user_Altitude": position.altitude,
//           "user_Latitude": position.latitude,
//           "user_Longitude": position.longitude,
//           "source": "Mobile"
//         }
//       };
//
//       await _restApiRepository.setPunchedOut(
//           variables: variables).then((val) async {
//         final punchStatus = await _restApiRepository.getPunchedStatus();
//
//         await _restApiRepository.getPunchedDetails(variables: {
//           "start_date": DateTime.parse("${event.todayDate} ${AppConstants.dateFixStart}").toIso8601String(),
//           "end_date": DateTime.parse("${event.todayDate} ${AppConstants.dateFixEnd}").toIso8601String(),
//           "user_id": auth.user!.userId
//         }).then((punchDetails) {
//           emit(HomeLoadedState(punchLogs: punchDetails, punchStatus: punchStatus));
//         }, onError: (e) {
//           emit(HomeErrorState(message: e.toString()));
//         });
//       }, onError: (e) {
//         emit(HomeErrorState(message: e.toString()));
//       });
//     } else {
//       emit(HomeErrorState(message: R.strings.msgNotAllowedPP));
//     }*/
//   } catch (e) {
//     emit(HomeErrorState(message: e.toString()));
//   }
// }
}

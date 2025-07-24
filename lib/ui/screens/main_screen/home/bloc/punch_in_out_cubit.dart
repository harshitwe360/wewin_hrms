import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';

part 'punch_in_out_state.dart';

class PunchInOutCubit extends Cubit<PunchInOutState> {
  PunchInOutCubit() : super(PInOutInitState());

  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  Future<void> punchIn() async {
    emit(PInOutLoadingState());
    try {
      String? serverDeviceId = await AuthService.instance.getServerDeviceId();
      if (!(serverDeviceId != null && serverDeviceId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const PInOutErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }
      print("step 1");

      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const PInOutErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      print("step 2");
      // if(auth.user == null || !auth.user!.isAttendance){
      //   emit(PInOutErrorState(message: R.strings.msgNotAllowedPP));
      //   return Future(() => false);
      // }

      print("step 3");
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(PInOutErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      print("step 4");
      // final Map<String, dynamic> deviceInfoJson = await GeoLocation.getDeviceInfo();
      print("step 5");
      // final bg.Location position = await GeoLocation.getCurrentPosition();
      print("step 6");
      // final Position position = await _determinePosition();
      // if (_isGeoFencing(auth, position.coords.latitude, position.coords.longitude)) {


      final Map<String, dynamic> variables = {
        // "id": auth.user!.pk,
        // "time_in": DateTime.now().toUtc().toIso8601String(),
        // "device": {"id": serverDeviceId},
        // "in_tracker": {"ip":"0.0.0.0", "coords":{
        //   "accuracy": position.coords.accuracy,
        //   "altitude": position.coords.altitude,
        //   "altitude_accuracy": position.coords.altitudeAccuracy,
        //   "heading_accuracy": position.coords.headingAccuracy,
        //   "speed_accuracy": position.coords.speedAccuracy,
        //   "speed": position.coords.speed,
        //   "latitude": position.coords.latitude,
        //   "longitude": position.coords.longitude,
        //   "source": "DEVICE"
        // }},
        // "device_info": json.encode(deviceInfoJson)
      };

      await _restApiRepository.setPunchedIn(
          variables: variables).then((seconds) async {
            print("totalWorkedSeconds : $seconds");
        emit(PInOutLoadedState(totalWorkedSeconds: seconds));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(PInOutUnAuthState(message: e.toString()));
        } else {
          emit(PInOutErrorState(message: e.toString()));
        }
      });
      /*} else {
        emit(HomeErrorState(message: R.strings.msgNotAllowedPP));
      }*/
    } catch (e) {
      emit(PInOutErrorState(message: e.toString()));
    }
  }

  Future<void> punchOut({required String punchOutId}) async {
    emit(PInOutLoadingState());
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const PInOutErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      // if(auth.user == null || !auth.user!.isAttendance){
      //   emit(PInOutErrorState(message: R.strings.msgNotAllowedPP));
      //   return Future(() => false);
      // }

      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(PInOutErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      // final bg.Location position = await GeoLocation.getCurrentPosition();
      // if (_isGeoFencing(auth, position.coords.latitude, position.coords.longitude)) {
        // final Map<String, dynamic> deviceInfoJson = await GeoLocation.getDeviceInfo();
        final Map<String, dynamic> variables = {
          // "id": punchOutId,
          // "userId": auth.user!.pk,
          // "device_info": json.encode(deviceInfoJson),
          // "ip":"0.0.0.0", "coords": {
          //   "accuracy": position.coords.accuracy,
          //   "altitude": position.coords.altitude,
          //   "altitude_accuracy": position.coords.altitudeAccuracy,
          //   "heading_accuracy": position.coords.headingAccuracy,
          //   "speed_accuracy": position.coords.speedAccuracy,
          //   "speed": position.coords.speed,
          //   "latitude": position.coords.latitude,
          //   "longitude": position.coords.longitude,
          //   "source": "DEVICE"
          // }
        };
        // print(" variables = ${json.encode(variables)}");

        await _restApiRepository.setPunchedIn(
            variables: variables).then((seconds) async {
          emit(PInOutLoadedState(totalWorkedSeconds: seconds));
        }, onError: (e) {
          if(e.toString() == RestApiRepositoryImp.errorStr){
            emit(PInOutUnAuthState(message: e.toString()));
          } else {
            emit(PInOutErrorState(message: e.toString()));
          }
        });
      // } else {
      //   emit(PInOutErrorState(message: R.strings.msgNotAllowedPP));
      // }
    } catch (e) {
      emit(PInOutErrorState(message: e.toString()));
    }
  }

  bool _isGeoFencing(AuthResponse auth, double currentLat, double currentLong) {
    // final List<GeofenceSet> geofenceSet = auth.user?.geofenceSet ?? [];
    // final bool isGeoFenceException = auth.user?.isGeoException ?? false;

    // if(geofenceSet.isEmpty || isGeoFenceException){
    //   return true;
    // }
    // for (var element in geofenceSet) {
    //   final double lat = element.coordinates.lat;
    //   final double long = element.coordinates.long;
    //   final double radius = element.coordinates.radius;
    //
    //   /*double distanceInMeters =
    //   Geolocator.distanceBetween(currentLat, currentLong, lat, long);
    //   debugPrint("GeofenceSet = $currentLat, $currentLong, :::: {$lat, $long, = radius $radius}");
    //   debugPrint("distanceInMeters = $distanceInMeters");
    //   debugPrint("radius = $radius");
    //   if(distanceInMeters <= radius) {
    //     return true;
    //   }*/
    // }

    return false;
  }

}

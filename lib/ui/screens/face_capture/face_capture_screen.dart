import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/apis/repository/attendance_repo.dart';
import '../../../core/config/config.dart';
import '../../../core/services/face_pose_evaluator.dart';
import 'bloc/face_punch_cubit.dart';
import 'face_punch_deps.dart';

/// Opens the system Settings page; returns whether it opened.
typedef SettingsOpener = Future<bool> Function(FacePunchIssue issue);

Future<bool> _defaultOpenSettings(FacePunchIssue issue) =>
    issue == FacePunchIssue.locationOff
        ? Geolocator.openLocationSettings()
        : Geolocator.openAppSettings();

/// Biometric punch screen. Pops with a [PunchResult] on success, or null
/// if the user cancels.
class FaceCaptureScreen extends StatelessWidget {
  const FaceCaptureScreen({
    super.key,
    required this.action,
    this.createCubit,
    this.openCamera = RealFaceCamera.open,
    this.openSettings = _defaultOpenSettings,
  });

  /// "in" or "out".
  final String action;

  /// Test hooks; defaults use the real camera, ML Kit, location and API.
  final FacePunchCubit Function()? createCubit;
  final FaceCameraOpener openCamera;
  final SettingsOpener openSettings;

  static Future<PunchResult?> open(BuildContext context, String action) =>
      Navigator.of(context).push<PunchResult>(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => FaceCaptureScreen(action: action)));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (createCubit?.call() ?? FacePunchCubit(action: action))..prepare(),
      child: _FaceCaptureView(
          action: action, openCamera: openCamera, openSettings: openSettings),
    );
  }
}

class _FaceCaptureView extends StatefulWidget {
  const _FaceCaptureView({
    required this.action,
    required this.openCamera,
    required this.openSettings,
  });

  final String action;
  final FaceCameraOpener openCamera;
  final SettingsOpener openSettings;

  @override
  State<_FaceCaptureView> createState() => _FaceCaptureViewState();
}

class _FaceCaptureViewState extends State<_FaceCaptureView>
    with WidgetsBindingObserver {
  FaceCamera? _camera;

  /// True while the camera is being opened. The OS permission prompt makes
  /// the app "inactive", which must not cancel the flow.
  bool _initializing = false;

  /// Set when the user went to Settings, so returning retries automatically.
  bool _awaitingSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final FaceCamera? c = _camera;
    _camera = null;
    c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettings) {
      // Back from Settings: try again with the (maybe) new permission.
      _awaitingSettings = false;
      context.read<FacePunchCubit>().prepare();
      return;
    }
    if (_initializing) return;
    // The camera must be released when the app leaves the foreground.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      context.read<FacePunchCubit>().interrupt();
      _disposeCamera();
    }
  }

  Future<void> _startCamera(FacePunchCubit cubit) async {
    if (_initializing) return;
    _initializing = true;
    FaceCamera? camera;
    try {
      await _disposeCamera();
      camera = await widget.openCamera();
    } catch (e) {
      _initializing = false;
      cubit.cameraFailed(e);
      return;
    }
    _initializing = false;
    if (!mounted || cubit.isClosed) {
      await camera.dispose();
      return;
    }
    setState(() => _camera = camera);
    await cubit.runCapture(camera);
  }

  Future<void> _disposeCamera() async {
    final FaceCamera? c = _camera;
    if (c == null) return;
    _camera = null;
    if (mounted) setState(() {});
    await c.dispose();
  }

  Future<void> _openSettings(FacePunchIssue issue) async {
    _awaitingSettings = true;
    final bool opened = await widget.openSettings(issue);
    if (!opened) {
      _awaitingSettings = false;
      if (mounted) {
        AppHelper.showSnackBar(context,
            snackBarMode: SnackBarMode.error,
            content: "Couldn't open Settings. Open it from your phone's Settings app.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.action == "in" ? "Verify to Punch In" : "Verify to Punch Out";
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SafeArea(
        child: BlocConsumer<FacePunchCubit, FacePunchState>(
          listenWhen: (p, c) => p.step != c.step,
          listener: (context, state) {
            final cubit = context.read<FacePunchCubit>();
            switch (state.step) {
              case FacePunchStep.capturing:
                _startCamera(cubit);
              case FacePunchStep.done:
                _disposeCamera();
                Navigator.of(context).pop(state.result);
              case FacePunchStep.failed:
                _disposeCamera();
                if (state.signedOut) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (r) => false);
                }
              default:
                break;
            }
          },
          builder: (context, state) => switch (state.step) {
            FacePunchStep.idle ||
            FacePunchStep.checkingLocation ||
            FacePunchStep.startingSession =>
              _progress(state.step == FacePunchStep.checkingLocation
                  ? "Checking your location…"
                  : "Starting face verification…"),
            FacePunchStep.capturing ||
            FacePunchStep.submitting ||
            FacePunchStep.done =>
              _capture(state),
            FacePunchStep.failed => _failed(context, state),
          },
        ),
      ),
    );
  }

  Widget _progress(String text) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.white)),
        ]),
      );

  Widget _capture(FacePunchState state) {
    final FaceCamera? c = _camera;
    final bool submitting = state.step != FacePunchStep.capturing;
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          submitting ? "Verifying…" : FacePoseEvaluator.instruction(state.pose),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _stepDots(state.frameIndex),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 260,
              height: 340,
              child: ClipOval(
                child: c != null
                    ? c.preview()
                    : const ColoredBox(
                        color: Colors.white10,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white))),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: submitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(state.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _stepDots(int done) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < done ? AppColors.punchIn : Colors.white24,
            ),
          );
        }),
      );

  Widget _failed(BuildContext context, FacePunchState state) {
    final IconData icon = switch (state.issue) {
      FacePunchIssue.cameraDenied || FacePunchIssue.cameraError =>
        Icons.no_photography_outlined,
      FacePunchIssue.locationOff ||
      FacePunchIssue.locationDenied ||
      FacePunchIssue.locationBlocked ||
      FacePunchIssue.outsideLocation =>
        Icons.location_off_outlined,
      _ => Icons.error_outline,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.punchOut, size: 56),
          const SizedBox(height: 16),
          Text(state.error ?? "Face verification failed.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 24),
          if (state.issue.needsSettings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                onPressed: () => _openSettings(state.issue),
                icon: const Icon(Icons.settings_outlined),
                label: Text(state.issue == FacePunchIssue.locationOff
                    ? "Turn on location"
                    : "Open Settings"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.punchIn,
                    foregroundColor: Colors.white),
              ),
            ),
          if (state.canRetry)
            state.issue.needsSettings
                ? OutlinedButton(
                    onPressed: () => context.read<FacePunchCubit>().prepare(),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54)),
                    child: const Text("Try again"),
                  )
                : ElevatedButton(
                    onPressed: () => context.read<FacePunchCubit>().prepare(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.punchIn,
                        foregroundColor: Colors.white),
                    child: const Text("Try again"),
                  ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
        ]),
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
  runApp(const PoseRunnerApp());
}

class PoseRunnerApp extends StatelessWidget {
  const PoseRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFC107),
      ),
      home: const CameraCheckScreen(),
    );
  }
}

/// Session 1 screen: proves the front camera opens and shows its details.
/// Session 2 adds the pose skeleton on top of this preview.
class CameraCheckScreen extends StatefulWidget {
  const CameraCheckScreen({super.key});

  @override
  State<CameraCheckScreen> createState() => _CameraCheckScreenState();
}

class _CameraCheckScreenState extends State<CameraCheckScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _camera;
  CameraProblem? _problem;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // While the permission dialog is open the app goes inactive; the start
    // call is still running then, so we only react when it is not.
    if (_starting) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stop();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _start();
    }
  }

  Future<void> _stop() async {
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    if (mounted) setState(() {});
    await controller.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _problem = null;
    });
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      final camera = pickFrontCamera(cameras);
      if (camera == null) {
        if (mounted) {
          setState(() {
            _problem = CameraProblem.noCamera;
            _starting = false;
          });
        }
        return;
      }
      controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = camera;
        _controller = controller;
        _starting = false;
      });
    } on Object catch (error) {
      await controller?.dispose();
      if (mounted) {
        setState(() {
          _problem = classifyCameraError(error);
          _starting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _buildPreview()),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_starting) {
      return const Center(child: CircularProgressIndicator());
    }
    final problem = _problem;
    if (problem != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.videocam_off, size: 48),
              const SizedBox(height: 16),
              Text(
                problemMessage(problem),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _start, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return ClipRect(child: Center(child: CameraPreview(controller)));
  }

  Widget _buildInfo() {
    final camera = _camera;
    final controller = _controller;
    final size = controller?.value.previewSize;
    final lines = <String>[
      if (camera != null) 'Camera: ${camera.name}',
      if (camera != null) 'Lens: ${camera.lensDirection.name}',
      if (camera != null) 'Sensor orientation: ${camera.sensorOrientation} deg',
      if (size != null)
        'Preview size: ${size.width.toInt()} x ${size.height.toInt()}',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.black54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Session 1 check',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (lines.isEmpty)
            const Text('No camera running.')
          else
            ...lines.map(Text.new),
          const SizedBox(height: 8),
          const Text('If you can see yourself above, Session 1 passes.'),
        ],
      ),
    );
  }
}

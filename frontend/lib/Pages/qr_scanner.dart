import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/Pages/mypage.dart';

class QRScan extends StatelessWidget {
  final List<CameraDescription> cameras;

  const QRScan({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "냉장고 QR 스캔",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPage(cameras: cameras),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          "<",
                          style: TextStyle(
                            color: Color(0xFF449c4a),
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CameraScreen(cameras: cameras), // 카메라 화면 추가
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      _controller = CameraController(widget.cameras[0], ResolutionPreset.high);

      await _controller?.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      // Handle the error, e.g., show an alert or fallback UI
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.transparent,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text(
                  "냉장고 QR 코드를 스캔해주세요.",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF8EC96D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/Pages/friger/food_create_with_cam.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
// For File operations

class BillScan extends StatefulWidget {
  final List<CameraDescription> cameras;

  const BillScan({super.key, required this.cameras});

  @override
  State<BillScan> createState() => _BillScanState();
}

class _BillScanState extends State<BillScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 2,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "영수증 스캔",
          style: TextStyle(
              fontSize: 24,
              fontFamily: 'GmarketSansMedium',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Expanded(
        child: CameraScreen(cameras: widget.cameras),
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
  bool _isLoading = false; // Add this flag to manage loading state

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

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    if (_controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }

    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _isLoading = true; // Set loading state to true
      });
      await _sendPicture(file);
    } catch (e) {
      setState(() {
        _isLoading = false; // Reset loading state on error
      });
    }
  }

  Future<void> _sendPicture(XFile file) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/process_bill');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        List<Map<String, dynamic>> ingredients = [];

        for (Map<String, dynamic> element in decodedData) {
          ingredients.add(element);
        }

        setState(() {
          _isLoading = false; // Reset loading state
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FoodCreateSwipe(
                    frigerId: 1,
                    ingredients: ingredients,
                  )),
        );
      } else {
        setState(() {
          _isLoading = false; // Reset loading state on failure
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Reset loading state on error
      });
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

    return SafeArea(
      top: true,
      bottom: false, // Set bottom to false to extend the preview to the bottom
      child: Stack(
        children: [
          CameraPreview(_controller!),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 300,
                  height: 550,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: Container(
                color: Colors.black54,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

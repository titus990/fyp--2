import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/analysis_service.dart';

class PunchAnalysisPage extends StatefulWidget {
  const PunchAnalysisPage({super.key});

  @override
  State<PunchAnalysisPage> createState() => _PunchAnalysisPageState();
}

class _PunchAnalysisPageState extends State<PunchAnalysisPage> {
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();
  final AnalysisService _analysisService = AnalysisService();
  
  bool _isAnalyzing = false;
  Map<String, dynamic>? _results;
  String? _errorMessage;

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 10),
      );
      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
          _results = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error picking video: $e";
      });
    }
  }

  Future<void> _analyzePunch() async {
    if (_videoFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final results = await _analysisService.analyzePunch(XFile(_videoFile!.path));
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Strike Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildVideoSection(),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_isAnalyzing)
              const Column(
                children: [
                   CircularProgressIndicator(color: Color(0xFFFF416C)),
                   SizedBox(height: 12),
                   Text("Analyzing Form...", style: TextStyle(color: Colors.white70)),
                ],
              ),
            
            if (_results != null) _buildResultsView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _videoFile == null || _isAnalyzing 
            ? null 
            : _analyzePunch,
        backgroundColor: _videoFile == null 
            ? Colors.grey 
            : const Color(0xFFFF416C),
        icon: const Icon(Icons.analytics_outlined),
        label: const Text("Analyze Strike"),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: _videoFile == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_outlined, size: 50, color: Colors.white54),
                const SizedBox(height: 12),
                const Text(
                  "Record or Upload a Punch",
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickVideo(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2193B0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickVideo(ImageSource.gallery),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 50, color: Colors.greenAccent),
                const SizedBox(height: 12),
                const Text(
                  "Video Selected",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextButton(
                  onPressed: () => _pickVideo(ImageSource.camera),
                  child: const Text("Retake", style: TextStyle(color: Colors.redAccent)),
                )
              ],
            ),
    );
  }

  Widget _buildResultsView() {
    final score = _results!['score'] ?? 0;
    final feedback = List<String>.from(_results!['feedback'] ?? []);
    final metrics = _results!['metrics'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D976C), Color(0xFF93F9B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Strike Score", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("TECHNIQUE", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Text(
                "$score",
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Velocity", 
                "${metrics['max_velocity'] ?? 0} px/s",
                Icons.speed,
                const Color(0xFF6DD5ED)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                "Extension", 
                "${metrics['max_extension'] ?? 0}°",
                Icons.straighten,
                const Color(0xFFFF8E53)
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
        const Text("COACH FEEDBACK", style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...feedback.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(f, style: const TextStyle(color: Colors.white))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}

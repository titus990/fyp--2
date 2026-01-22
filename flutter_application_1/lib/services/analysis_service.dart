import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AnalysisService {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use localhost for iOS simulator or desktop
  // Replace with local IP if testing on real device
  static const String baseUrl = 'http://10.0.2.2:5000'; 
  
  Future<Map<String, dynamic>> analyzePunch(XFile videoFile) async {
    var uri = Uri.parse('$baseUrl/analyze_punch');
    var request = http.MultipartRequest('POST', uri);
    
    request.files.add(await http.MultipartFile.fromPath(
      'video',
      videoFile.path,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze video: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(AiBodyAnalysisApp());
}

class AiBodyAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E2C),
        primaryColor: Colors.purpleAccent,
        textTheme: TextTheme(
         bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: BodyAnalysisScreen(),
    );
  }
}

class BodyAnalysisScreen extends StatefulWidget {
  @override
  _BodyAnalysisScreenState createState() => _BodyAnalysisScreenState();
}

class _BodyAnalysisScreenState extends State<BodyAnalysisScreen> {
  File? _selectedImage;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isAnalyzing = false;
  String? _analysisResult;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _analyzeBody() async {
    if (_selectedImage == null || _heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image and enter height & weight.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:5000/analyze"), 
    );
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    request.fields['height'] = _heightController.text;
    request.fields['weight'] = _weightController.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResult = jsonDecode(responseData);
      setState(() {
        _isAnalyzing = false;
        _analysisResult = jsonResult["result"];
      });
    } else {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error analyzing image. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Body Analysis", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Upload a full-body photo", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent, width: 2),
                ),
                child: _selectedImage == null
                    ? Icon(Icons.camera_alt, size: 50, color: Colors.purpleAccent)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 20),
            _buildInputField("Enter Height (cm)", _heightController),
            _buildInputField("Enter Weight (kg)", _weightController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _analyzeBody,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Analyze", style: TextStyle(fontSize: 18)),
            ).animate().fade(duration: 500.ms).scale(),
            SizedBox(height: 20),
                       _isAnalyzing
                ? Lottie.asset('assets/loading.json', height: 100) 
                : _analysisResult != null
                    ? Animate(
                        child: Text(
                          _analysisResult!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ).fade(duration: 700.ms).slideY()
                    : SizedBox(), // <-- Added fallback for when there's no result

          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.purpleAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purpleAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ).animate().fade(duration: 400.ms);
  }
}

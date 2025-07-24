import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CropYieldPredictorPage(),
    );
  }
}


class CropYieldPredictorPage extends StatefulWidget {
  const CropYieldPredictorPage({Key? key}) : super(key: key);

  @override
  State<CropYieldPredictorPage> createState() => _CropYieldPredictorPageState();
}

class _CropYieldPredictorPageState extends State<CropYieldPredictorPage> {
  final _formKey = GlobalKey<FormState>();

  final _regionController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _cropController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _fertilizerController = TextEditingController();
  final _irrigationController = TextEditingController();
  final _weatherController = TextEditingController();
  final _daysToHarvestController = TextEditingController();

  String? _result;
  bool _loading = false;

  // Replace with your actual Render FastAPI URL
  static const String apiUrl = 'https://linear-regression-model-9w94.onrender.com/predict';

  @override
  void dispose() {
    _regionController.dispose();
    _soilTypeController.dispose();
    _cropController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    _fertilizerController.dispose();
    _irrigationController.dispose();
    _weatherController.dispose();
    _daysToHarvestController.dispose();
    super.dispose();
  }

  Future<void> _predictYield() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Region": _regionController.text.trim(),
          "Soil_Type": _soilTypeController.text.trim(),
          "Crop": _cropController.text.trim(),
          "Rainfall_mm": double.tryParse(_rainfallController.text.trim()) ?? 0.0,
          "Temperature_Celsius": double.tryParse(_temperatureController.text.trim()) ?? 0.0,
          "Fertilizer_Used": _fertilizerController.text.trim(),
          "Irrigation_Used": _irrigationController.text.trim(),
          "Weather_Condition": _weatherController.text.trim(),
          "Days_to_Harvest": int.tryParse(_daysToHarvestController.text.trim()) ?? 0,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = "Predicted Yield: ${data['predicted_yield_ton_per_ha']}";
        });
      } else {
        setState(() {
          _result = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
      print("Error during prediction: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      String? Function(String?)? validator,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Yield Predictor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'Region',
                  controller: _regionController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter region' : null,
                ),
                _buildTextField(
                  label: 'Soil Type',
                  controller: _soilTypeController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter soil type' : null,
                ),
                _buildTextField(
                  label: 'Crop',
                  controller: _cropController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter crop' : null,
                ),
                _buildTextField(
                  label: 'Rainfall (mm)',
                  controller: _rainfallController,
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Enter valid rainfall';
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  label: 'Temperature (°C)',
                  controller: _temperatureController,
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null) return 'Enter valid temperature';
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  label: 'Fertilizer Used',
                  controller: _fertilizerController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter fertilizer used' : null,
                ),
                _buildTextField(
                  label: 'Irrigation Used',
                  controller: _irrigationController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter irrigation used' : null,
                ),
                _buildTextField(
                  label: 'Weather Condition',
                  controller: _weatherController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter weather condition' : null,
                ),
                _buildTextField(
                  label: 'Days to Harvest',
                  controller: _daysToHarvestController,
                  validator: (v) {
                    final val = int.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Enter valid days';
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _predictYield,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Predict'),
                ),
                const SizedBox(height: 16),
                if (_result != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _result!,
                      style: TextStyle(
                        color: _result!.startsWith('Predicted') ? Colors.green[800] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

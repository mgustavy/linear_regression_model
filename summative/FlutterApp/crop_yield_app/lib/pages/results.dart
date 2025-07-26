import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final double predictedYield;

  const ResultPage({Key? key, required this.predictedYield}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prediction Result')),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Predicted Yield: ${predictedYield.toStringAsFixed(2)} tons/hectare',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
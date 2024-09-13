import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://127.0.0.1:8000';

class UsePointsPage extends StatefulWidget {
  const UsePointsPage({Key? key}) : super(key: key);

  @override
  _UsePointsPageState createState() => _UsePointsPageState();
}

class _UsePointsPageState extends State<UsePointsPage> {
  int _selectedAmount = 10000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보유 중인 그린 포인트',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              '0 gp',
              style: TextStyle(fontSize: 30, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildRadioButton(10000, '10000원'),
                  _buildRadioButton(20000, '20000원'),
                  _buildRadioButton(30000, '30000원'),
                  _buildRadioButton(40000, '40000원'),
                  _buildRadioButton(50000, '50000원'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updatePoints(_selectedAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '변경하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(int value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAmount == value ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              _selectedAmount == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _selectedAmount == value ? const Color(0xFF4CAF50) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: _selectedAmount == value ? const Color(0xFF4CAF50) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePoints(int amount) async {
    final response = await http.post(
      Uri.parse('$apiUrl/update-points'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{'amount': amount}),
    );

    if (response.statusCode == 200) {
      print('Points updated successfully');
    } else {
      print('Failed to update points');
    }
  }
}

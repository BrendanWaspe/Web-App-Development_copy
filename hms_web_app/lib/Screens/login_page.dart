import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // To store any error messages
  bool _isLoading = false; // To show loading state

  Future<void> login() async {
    setState(() {
      _isLoading = true; // Start loading
      _errorMessage = null; // Clear previous error
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5004/users/login'), // Adjust URL as necessary
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _usernameController.text,
          'userPassword': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Safely get token and ID from the response, checking for null
        final token = responseData['Token'] ?? ''; // Provide default value if null
        final id = responseData['ID'] ?? ''; // Provide default value if null

        if (token.isNotEmpty && id.isNotEmpty) {
          // Save the ID in shared_preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userID', id); // Store ID for session

          // Handle successful login, e.g., save the token and navigate
          print('Login successful! Token: $token');
          Navigator.pushNamed(context, '/dashboard'); // Navigate to the dashboard
        } else {
          setState(() {
            _errorMessage = 'Login failed: Invalid token or ID'; // Handle missing token/ID
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed: ${response.body}'; // Display error
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e'; // Display error
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 300, // Set a smaller width for the login form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Username TextField with label
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username", // Label for username
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Password TextField with label
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password", // Label for password
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),

                // Error message display
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),

                // Login Button
                SizedBox(
                  width: double.infinity, // Make the button stretch to the width of the form
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : login, // Disable when loading
                    child: _isLoading 
                      ? CircularProgressIndicator() 
                      : Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

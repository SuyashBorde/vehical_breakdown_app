import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:vehical_breakdown_app/login_page.dart';

class SmsVerification extends StatefulWidget {
  const SmsVerification({super.key});

  @override
  _SmsVerificationState createState() => _SmsVerificationState();
}

class _SmsVerificationState extends State<SmsVerification> {
  LocationData? _currentPosition;
  // ignore: unused_field
  String? _error;

  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          setState(() {
            _error = "Location services are disabled.";
          });
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          setState(() {
            _error = "Location permissions are denied.";
          });
          return;
        }
      }

      location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _currentPosition = currentLocation;
          _error = null; // Clear any previous error
        });
      });
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    }
  }

  Future<List<String>> _fetchContactsFromFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    List<String> phoneNumbers = [];
    String countryCode = "+91"; // Define your country code here

    if (currentUser != null) {
      final collectionName = currentUser.email;
      final firestore = FirebaseFirestore.instance;

      try {
        QuerySnapshot querySnapshot =
            await firestore.collection(collectionName!).get();
        for (var doc in querySnapshot.docs) {
          List<dynamic> phones = doc['phones'];
          for (var phone in phones) {
            // Add country code to the phone number if it doesn't have one
            String fullPhoneNumber =
                phone.startsWith('+') ? phone : countryCode + phone;
            phoneNumbers.add(fullPhoneNumber);
          }
        }
      } catch (e) {
        print("Error fetching contacts from Firestore: $e");
        Fluttertoast.showToast(msg: 'Failed to fetch contacts');
      }
    } else {
      print("No user logged in");
      Fluttertoast.showToast(msg: 'No user logged in');
    }

    return phoneNumbers;
  }

  Future<void> sendBulkSMS(String message, List<String> recipients) async {
    const String accountSid = 'AC9614e3c85803f0da676f385604f3499d';
    const String authToken = '45caead13515408c8888261fd5c2d80c';
    const String fromNumber = '+17855092782';

    const String url =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    for (String recipient in recipients) {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': fromNumber,
          'To': recipient,
          'Body': message,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'SMS sent successfully to $recipient');
        print('SMS sent successfully to $recipient');
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to send SMS to $recipient: ${response.body}');
        print('Failed to send SMS to $recipient: ${response.body}');
      }
    }
  }

  void _sendSOS() async {
    if (_currentPosition != null) {
      String message =
          "Hi, I need help! My current location is: Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}";
      List<String> recipients = await _fetchContactsFromFirestore();
      await sendBulkSMS(message, recipients);
    } else {
      Fluttertoast.showToast(msg: 'Unable to get current location');
      print('Unable to get current location');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SOS Page",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _sendSOS,
              child: Image.asset(
                'assets/images/sos_signal.jpg',
                width: 400, // Adjust the size as needed
                height: 400,
              ),
            ),
            const SizedBox(
              height: 200,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ContactList');
              },
              child: const Text(
                'Edit Your Contact List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

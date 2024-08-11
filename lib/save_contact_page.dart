import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SaveContactsPage extends StatefulWidget {
  const SaveContactsPage({super.key});

  @override
  State<SaveContactsPage> createState() => _SaveContactsPageState();
}

class _SaveContactsPageState extends State<SaveContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getCurrentUser();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      // Permissions granted
    } else {
      // Handle permission denial
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _fetchContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
      });
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  Future<void> _saveContactsToFirestore() async {
    final firestore = FirebaseFirestore.instance;

    if (_currentUser == null) {
      print("No user logged in");
      return;
    }

    final collectionName = _currentUser!.email;

    try {
      for (var contact in _selectedContacts) {
        String? profilePhotoBase64;
        if (contact.avatar != null && contact.avatar!.isNotEmpty) {
          profilePhotoBase64 = base64Encode(contact.avatar!);
        }

        // Filter out duplicate phone numbers
        final uniquePhones = contact.phones!
            .map((phone) => phone.value)
            .toSet()
            .toList(); // Using Set to remove duplicates

        await firestore.collection(collectionName!).add({
          'displayName': contact.displayName ?? 'No name',
          'phones': uniquePhones, // Save the unique phone numbers
          'profilePhotoUrl': profilePhotoBase64,
        });
      }

      // Optionally clear selected contacts after saving
      setState(() {
        _selectedContacts.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts saved to Firestore')),
      );

      Navigator.pop(context); // Navigate back to ContactListPage
    } catch (e) {
      print("Error saving contacts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save contacts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Save Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: _contacts.isNotEmpty
                  ? ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return ListTile(
                          title: Text(contact.displayName ?? 'No name'),
                          subtitle: Text(
                            contact.phones!.isNotEmpty
                                ? contact.phones?.first.value ?? 'No number'
                                : 'No number',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              _selectedContacts.contains(contact)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                            ),
                            onPressed: () => _toggleContactSelection(contact),
                          ),
                        );
                      },
                    )
                  : const Text("No contacts loaded"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _fetchContacts,
                  child: const Text("Load Contacts"),
                ),
                ElevatedButton(
                  onPressed: _saveContactsToFirestore,
                  child: const Text("Save Selected Contacts"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

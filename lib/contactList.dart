import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late User _currentUser;
  late String _collectionName;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _collectionName = _currentUser.email!;
  }

  Stream<QuerySnapshot> _getContactsStream() {
    return FirebaseFirestore.instance.collection(_collectionName).snapshots();
  }

  Future<ImageProvider> _getProfilePhoto(String? base64String) async {
    if (base64String == null || base64String.isEmpty) {
      return const AssetImage('assets/images/user.png'); // Default image
    }
    try {
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      print("Error decoding profile photo: $e");
      return const AssetImage('assets/images/user.png'); // Default image in case of error
    }
  }

  Future<void> _deleteContact(String docId) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(docId)
        .delete();
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteContact(docId); // Delete the contact
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getContactsStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final contactData = contact.data() as Map<String, dynamic>;
                      final displayName = contactData['displayName'] as String?;
                      final phones = List<String>.from(contactData['phones'] ?? []);
                      final profilePhotoBase64 = contactData['profilePhotoUrl'] as String?;

                      return ListTile(
                        leading: FutureBuilder<ImageProvider>(
                          future: _getProfilePhoto(profilePhotoBase64),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircleAvatar(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const CircleAvatar(child: Icon(Icons.error));
                            } else {
                              return CircleAvatar(
                                backgroundImage: snapshot.data,
                                radius: 25,
                              );
                            }
                          },
                        ),
                        title: Text(displayName ?? 'No name'),
                        subtitle: Text(
                          phones.isNotEmpty ? phones.join(', ') : 'No number',
                        ),
                        onLongPress: () {
                          _showDeleteConfirmationDialog(contact.id);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/SaveContacts');
                  },
                  child: const Text("Add Contacts"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

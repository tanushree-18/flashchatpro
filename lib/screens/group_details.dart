import 'package:flutter/material.dart';
import 'package:flashchat/components/rounded_button.dart';
import 'package:flashchat/constants.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'registration_screen.dart';

class GroupDetails extends StatelessWidget {
  static const String id = 'group_details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('userDetails').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final userDetails =
                  documents[index].data() as Map<String, dynamic>;
              final email = userDetails['email'];
              final userName = userDetails['user_name'];
              final profileImageUrl = userDetails['profile_image'];

              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/pink.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListTile(
                  leading: profileImageUrl != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(profileImageUrl),
                        )
                      : CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              AssetImage('images/default_avatar.png'),
                        ),
                  title: Text('Email: $email'),
                  subtitle: Text('User Name: $userName'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

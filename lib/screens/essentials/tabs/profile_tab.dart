import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locora/utils/redirects.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(radius: 40),

              const SizedBox(height: 10),

              Text(user?.email ?? "No Email"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  redirectAfterLogout(context);
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            
            Positioned(
              top: MediaQuery.of(context).padding.top, // Position right below the status bar
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80), // Adjust height as necessary
                  const Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 80), // Adjust height as necessary
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                        return;
                      }
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        if (userCredential.user != null) {
                          // it's safe to access userCredential.user.uid because we checked that user is not null
                          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                            'username': _nameController.text.trim(),
                            'email': _emailController.text.trim()
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully registered')),
                          );

                          // Navigate to the login page after showing success message
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pushNamed(context, '/login');
                          });
                        } else {
                          // Handle the case where the user is null, which means the user was not created
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to register user')),
                          );
                        }

                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('The email address is already in use by another account')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to register: ${e.message}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to register: $e')),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

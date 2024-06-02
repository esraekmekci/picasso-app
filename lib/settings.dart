import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _currentPasswordControllerForUsername = TextEditingController();
  final TextEditingController _currentPasswordControllerForPassword = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordControllerForUsername.dispose();
    _currentPasswordControllerForPassword.dispose();
    super.dispose();
  }

  Future<bool> _reauthenticateUser(String currentPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(email: user!.email!, password: currentPassword);
  
    try {
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reauthentication failed: $e')));
      return false;
    }
  }

  Future<void> _updateUsername() async {
    if (_currentPasswordControllerForUsername.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Current password is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isReauthenticated = await _reauthenticateUser(_currentPasswordControllerForUsername.text);

    if (isReauthenticated) {
      try {
        if (_usernameController.text.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
            'username': _usernameController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username updated successfully')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating username: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (_currentPasswordControllerForPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Current password is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isReauthenticated = await _reauthenticateUser(_currentPasswordControllerForPassword.text);

    if (isReauthenticated) {
      try {
        if (_passwordController.text.isNotEmpty) {
          await user!.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating password: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              ExpansionTile(
                title: Text('Update Username'),
                leading: Icon(Icons.person),
                children: <Widget>[
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'New Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _currentPasswordControllerForUsername,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updateUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('Update Username')),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              ExpansionTile(
                title: Text('Update Password'),
                leading: Icon(Icons.lock),
                children: <Widget>[
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _currentPasswordControllerForPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('Update Password')),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              if (_isLoading) LoadingGif(),
            ],
          ),
        ),
      ),
    );
  }
}

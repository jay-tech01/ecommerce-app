import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: [Colors.lightBlueAccent, Colors.white],
    ),
    ),
    child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Log In'),
            ),
          ],
        ),
      ),
    ),);
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Successfully signed in
      print('User signed in: ${userCredential.user?.uid}');

      // Update the ProfilePage by popping the current screen
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage()));

    } on FirebaseAuthException catch (e) {
      // Handle errors such as invalid email, wrong password, etc.
      print('Failed to sign in: $e');
      _showErrorDialog('Login Failed', e.message ?? 'An error occurred while signing in.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/signInScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _designation;
  bool obscurePassword = true;
  bool obscurePassword1 = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<String> _designations = [
    'Designer',
    'Developer',
    'Manager',
    'Tester'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _numberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Store user data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': _nameController.text,
            'email': _emailController.text,
            'number': _numberController.text,
            'location': _locationController.text,
            'password': _passwordController.text,
            'designation': _designation,
            'type': "Employee",
            'uid': user.uid,
            'picture': "",
            'about': "",
            'skills': ""
          });

          // Navigate to SignInScreen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        print('Failed with error code: ${e.code}');
        print(e.message);
        // Show error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 24,
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  Text(
                    "Let's create your \nAccount",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),

              // for the name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Name',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Email',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  suffixIcon: TextButton(
                    onPressed: () {
                      if (obscurePassword == false) {
                        setState(() => obscurePassword = true);
                      } else {
                        setState(() => obscurePassword = false);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade200),
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(obscurePassword == true ? 'SHOW' : 'HIDE',
                              style: TextStyle(
                                  fontSize: 8, color: Colors.grey.shade500))),
                    ),
                  ),
                ),
                obscureText: obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the password confirmation
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Confirm Password',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                  suffixIcon: TextButton(
                    onPressed: () {
                      if (obscurePassword1 == false) {
                        setState(() => obscurePassword1 = true);
                      } else {
                        setState(() => obscurePassword1 = false);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade200),
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              obscurePassword1 == true ? 'SHOW' : 'HIDE',
                              style: TextStyle(
                                  fontSize: 8, color: Colors.grey.shade500))),
                    ),
                  ),
                ),
                obscureText: obscurePassword1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the number
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Number',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Location',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // for the designation
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade300,
                  filled: true,
                  labelText: 'Designation',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none),
                ),
                value: _designation,
                items: _designations.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _designation = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your designation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                      _signUp();
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

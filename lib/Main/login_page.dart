// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Local imports

// ========== Login page ========== //
class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  // ===== Class Variables ===== //

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ===== Class Widgets ===== //

  // Email text field
  Widget emailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Password text field
  Widget passwordField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: true,
    );
  }

  // Sign in / up buttons
  Widget signInUpButtons() {
    return Column(
      children: [
        // Sign in button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // Button style
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.all(12),
            ),

            // Button action
            onPressed: () {},

            // Button label
            child: Text('Sign in'),
          ),
        ),

        // Padding
        SizedBox(height: 10),

        // Sign up button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // Button style
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.all(12),
            ),

            // Button action
            onPressed: () {},

            // Button label
            child: Text('Sign up'),
          ),
        ),

        // Padding
        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            // Button style
            style: TextButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.all(12),
            ),

            // Button action
            onPressed: () {},

            // Button label
            child: Text('Skip'),
          ),
        ),
      ],
    );
  }

  // Welcome splash
  Widget welcomeSplash(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // Logo
        SvgPicture.asset(
          'assets/settings/logo.svg',
          height: 200,
          color: Theme.of(context).colorScheme.primary,
        ),

        // Padding
        const SizedBox(height: 32),
        
        // Title
        Text(
          "Let's get started!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  // ===== Build Method ===== //

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures that the Column takes only as much space as needed
          children: [
            const SizedBox(height: 64),
            welcomeSplash(context),
            const SizedBox(height: 64),
            emailField(),
            const SizedBox(height: 16),
            passwordField(),
            const SizedBox(height: 16),
            signInUpButtons(),
          ],
        ),
      ),
    ),
  );
}

}

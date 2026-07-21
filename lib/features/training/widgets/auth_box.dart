import 'package:flutter/material.dart';

class AuthBox extends StatelessWidget {
  const AuthBox({
    super.key,
    required this.isSignedIn,
    required this.displayName,
    required this.emailController,
    required this.passwordController,
    required this.onAuthPressed,
  });

  final bool isSignedIn;
  final String displayName;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onAuthPressed;

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF281922),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFFFFB0CB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(onPressed: onAuthPressed, child: const Text('Logout')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF281922),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_rounded),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_rounded),
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAuthPressed,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}

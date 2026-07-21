import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import 'auth_box.dart';
import 'training_controls.dart';

class AccountPanel extends StatelessWidget {
  const AccountPanel({
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(icon: Icons.person_rounded, title: 'Account'),
          const SizedBox(height: 12),
          AuthBox(
            isSignedIn: isSignedIn,
            displayName: displayName,
            emailController: emailController,
            passwordController: passwordController,
            onAuthPressed: onAuthPressed,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Text(
              'Saving settings, custom cues, and training stats requires login.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

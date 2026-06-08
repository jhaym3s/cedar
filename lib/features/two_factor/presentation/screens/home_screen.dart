import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/enrollment/enrollment_bloc.dart';
import '../../bloc/enrollment/enrollment_event.dart';
import '../../bloc/verification/verification_bloc.dart';
import '../../data/two_factor_repository.dart';
import 'disable_2fa_stub_screen.dart';
import 'enrollment_screen.dart';
import 'verification_screen.dart';

/// Minimal host UI representing the relevant slice of the Cedar wallet.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _enabled = false;

  Future<void> _enroll() async {
    final repo = context.read<TwoFactorRepository>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EnrollmentBloc(repo)..add(const EnrollmentStarted()),
          child: const EnrollmentScreen(),
        ),
      ),
    );
    if (result == true && mounted) setState(() => _enabled = true);
  }

  Future<void> _verify() async {
    final repo = context.read<TwoFactorRepository>();
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => VerificationBloc(repo),
          child: const VerificationScreen(),
        ),
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer approved ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cedar Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(_enabled ? Icons.verified_user : Icons.shield,
                  color: _enabled ? Colors.green : Colors.grey),
              title: const Text('App-based 2FA'),
              subtitle: Text(_enabled ? 'Enabled' : 'Not set up'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.qr_code),
            label: Text(_enabled ? 'Re-enroll authenticator' : 'Set up 2FA'),
            onPressed: _enroll,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Send money (demo sensitive action)'),
            onPressed: _enabled ? _verify : null,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const Disable2faStubScreen()),
            ),
            child: const Text('Disable 2FA (stub)'),
          ),
        ],
      ),
    );
  }
}
import 'package:cedar/features/security/bloc/enrollment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../data/repository.dart';
import 'enrollment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _enabled = false;

  Future<void> _enroll() async {
    final repo = context.read<TOTPRepository>();
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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cedar Merchant')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(_enabled ? Icons.verified_user : Icons.shield,
                    color: _enabled ? Colors.green : Colors.grey),
                title: const Text('App based 2FA'),
                subtitle: Text(_enabled ? 'Enabled' : 'Not set up'),
              ),
            ),


            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.qr_code),
              label: Text(_enabled ? 'Re enroll authenticator' : 'Set up TOTP authenticator'),
              onPressed: _enroll,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
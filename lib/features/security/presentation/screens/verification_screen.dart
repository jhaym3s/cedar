import 'dart:async';

import 'package:cedar/features/security/bloc/verification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/code_input.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, this.amountLabel = '\$250.00 to Jhaymes'});
  final String amountLabel;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length == 6) {
      context.read<VerificationBloc>().add(VerificationCodeSubmitted(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve transfer')),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state.status == VerificationStatus.success) {
            Navigator.of(context).pop(true);
          }
          if (state.status == VerificationStatus.invalid) {
            _controller.clear();
          }
        },
        builder: (context, state) {
          final locked = state.status == VerificationStatus.lockedOut;
          final busy = state.status == VerificationStatus.verifying;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.send),
                    title: Text('Sending ${widget.amountLabel}'),
                    subtitle: const Text('Confirm with your authenticator'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Enter the 6-digit code',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                CodeInput(
                  controller: _controller,
                  enabled: !locked && !busy,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                if (state.status == VerificationStatus.invalid)
                  Text(
                    'Incorrect code. ${state.attemptsRemaining} '
                    '${state.attemptsRemaining == 1 ? "attempt" : "attempts"} left.',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                if (state.status == VerificationStatus.error)
                  Text(state.errorMessage ?? 'Error',
                      style: const TextStyle(color: Colors.redAccent)),
                if (locked) _LockoutBanner(retryAfter: state.retryAfter!),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: (locked || busy) ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Approve'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Counts down the lockout window and re-enables the form when it elapses.
class _LockoutBanner extends StatefulWidget {
  const _LockoutBanner({required this.retryAfter});
  final Duration retryAfter;
  @override
  State<_LockoutBanner> createState() => _LockoutBannerState();
}

class _LockoutBannerState extends State<_LockoutBanner> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.retryAfter.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        context.read<VerificationBloc>().add(const VerificationReset());
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Too many incorrect codes. Try again in $_seconds s.',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
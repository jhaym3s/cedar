import 'package:cedar/features/security/bloc/enrollment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';


import '../widgets/code_input.dart';

class EnrollmentScreen extends StatelessWidget {
  const EnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up authenticator app')),
      body: BlocConsumer<EnrollmentBloc, EnrollmentState>(
        listener: (context, state) {
          if (state.status == EnrollmentStatus.completed) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            EnrollmentStatus.initial ||
            EnrollmentStatus.loadingSecret =>
              const _Loading(),
            EnrollmentStatus.awaitingCode ||
            EnrollmentStatus.confirming ||
            EnrollmentStatus.confirmInvalid =>
              _QrAndConfirm(state: state),
            EnrollmentStatus.showingRecoveryCodes =>
              _RecoveryCodes(codes: state.recoveryCodes),
            EnrollmentStatus.completed => const _Loading(),
            EnrollmentStatus.error => _ErrorView(message: state.errorMessage),
          };
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message});
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message ?? 'Something went wrong'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.read<EnrollmentBloc>().add(const EnrollmentStarted()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _QrAndConfirm extends StatefulWidget {
  const _QrAndConfirm({required this.state});
  final EnrollmentState state;
  @override
  State<_QrAndConfirm> createState() => _QrAndConfirmState();
}

class _QrAndConfirmState extends State<_QrAndConfirm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length == 6) {
      context.read<EnrollmentBloc>().add(EnrollmentCodeSubmitted(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final busy = state.status == EnrollmentStatus.confirming;
    final invalid = state.status == EnrollmentStatus.confirmInvalid;
    final secret = state.secret ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('1. Scan this QR code with your authenticator app',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                data: state.otpauthUri ?? '',
                size: 200,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Can't scan? Enter this key manually:"),
          const SizedBox(height: 8),
          _ManualKey(secret: secret),
          const SizedBox(height: 32),
          const Text('2. Enter the 6-digit code from the app',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          CodeInput(
            controller: _controller,
            enabled: !busy,
            onSubmitted: (_) => _submit(),
          ),
          if (invalid)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('That code was incorrect. Try the current code.',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Verify & enable'),
          ),
        ],
      ),
    );
  }
}

class _ManualKey extends StatelessWidget {
  const _ManualKey({required this.secret});
  final String secret;

  String get _formatted {
    final buf = StringBuffer();
    for (var i = 0; i < secret.length; i += 4) {
      final end = (i + 4 < secret.length) ? i + 4 : secret.length;
      buf.write(secret.substring(i, end));
      if (end < secret.length) buf.write(' ');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              _formatted,
             
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: secret)),
          ),
        ],
      ),
    );
  }
}

class _RecoveryCodes extends StatefulWidget {
  const _RecoveryCodes({required this.codes});
  final List<String> codes;
  @override
  State<_RecoveryCodes> createState() => _RecoveryCodesState();
}

class _RecoveryCodesState extends State<_RecoveryCodes> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Save your recovery codes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
              'Each code works once if you lose access to your authenticator. '
              'Store them somewhere safe — they will not be shown again.'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: widget.codes
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SelectableText(c,
                            ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy all'),
            onPressed: () => Clipboard.setData(
                ClipboardData(text: widget.codes.join('\n'))),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _saved,
            onChanged: (v) => setState(() => _saved = v ?? false),
            title: const Text('I have saved these codes'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saved
                ? () => context
                    .read<EnrollmentBloc>()
                    .add(const RecoveryCodesAcknowledged())
                : null,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
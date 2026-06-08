import 'package:equatable/equatable.dart';


class EnrollStartResponse extends Equatable {
  const EnrollStartResponse({required this.secret, required this.otpauthUri});

  final String secret;
  final String otpauthUri;

  @override
  List<Object?> get props => [secret, otpauthUri];

}

class ConfirmResponse extends Equatable {
  const ConfirmResponse({required this.recoveryCodes});

  final List<String> recoveryCodes;

  @override
  List<Object?> get props => [recoveryCodes];

  
}
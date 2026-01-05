import 'dart:async';
import 'package:uuid/uuid.dart';

class AuthRepository {
  AuthRepository();

  final _controller = StreamController<String?>.broadcast();
  String? _userId;

  Stream<String?> authStateChanges() => _controller.stream;

  String? get currentUserId => _userId;

  Future<String> ensureSignedIn() async {
    _userId ??= const Uuid().v4();
    _controller.add(_userId);
    return _userId!;
  }
}

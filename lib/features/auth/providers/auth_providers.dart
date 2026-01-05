import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).maybeWhen(
        data: (userId) => userId,
        orElse: () => ref.read(authRepositoryProvider).currentUserId,
      );
});

final authInitializerProvider = FutureProvider<bool>((ref) async {
  await ref.read(authRepositoryProvider).ensureSignedIn();
  return true;
});

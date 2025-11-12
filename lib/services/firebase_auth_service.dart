import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:run/firebase_options.dart';

/// Wrapper simples que só acessa FirebaseAuth após inicialização bem-sucedida.
class FirebaseAuthService {
  static Future<bool> ensureInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser =>
      Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;

  Future<UserCredential> signIn(String email, String password) async {
    final auth = FirebaseAuth.instance;
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> safeSignIn(String email, String password) async {
    final ok = await ensureInitialized();
    if (!ok) return null;
    try {
      return await signIn(email, password);
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<UserCredential> register(String email, String password) async {
    final auth = FirebaseAuth.instance;
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> safeRegister(String email, String password) async {
    final ok = await ensureInitialized();
    if (!ok) return null;
    try {
      return await register(email, password);
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<void> updateDisplayName(String name) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await user.updateDisplayName(name);
  }

  Future<void> updatePassword(String newPassword) async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordReset(String email) async {
    if (Firebase.apps.isEmpty) return;
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    if (Firebase.apps.isEmpty) return;
    await FirebaseAuth.instance.signOut();
  }
}

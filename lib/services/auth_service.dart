// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // ✅ Get current logged-in user
//   User? get currentUser => _auth.currentUser;

//   // ===========================
//   // 🔹 Sign Up
//   // ===========================
//   Future<User?> signUp({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final UserCredential credential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);
//       return credential.user;
//     } on FirebaseAuthException catch (e) {
//       // Debug print, do not remove
//       print("❌ SignUp Error: ${e.code} - ${e.message}");
//       rethrow; // Pass error to UI if needed
//     } catch (e) {
//       print("❌ SignUp Unknown Error: $e");
//       rethrow;
//     }
//   }

//   // ===========================
//   // 🔹 Login
//   // ===========================
//   Future<User?> login({required String email, required String password}) async {
//     try {
//       final UserCredential credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return credential.user;
//     } on FirebaseAuthException catch (e) {
//       print("❌ Login Error: ${e.code} - ${e.message}");
//       rethrow;
//     } catch (e) {
//       print("❌ Login Unknown Error: $e");
//       rethrow;
//     }
//   }

//   // ===========================
//   // 🔹 Logout
//   // ===========================
//   Future<void> logout() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       print("❌ Logout Error: $e");
//       rethrow;
//     }
//   }

//   // ===========================
//   // 🔹 Auth State Changes Stream
//   // Useful for listeners / AuthGuard
//   // ===========================
//   Stream<User?> authStateChanges() {
//     return _auth.authStateChanges();
//   }

//   // ===========================
//   // 🔹 Get ID Token for Backend
//   // Useful for FastAPI / server verification
//   // ===========================
//   Future<String?> getIdToken() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       return await user.getIdToken();
//     }
//     return null;
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return cred.user;
  }

  Future<User?> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return cred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}

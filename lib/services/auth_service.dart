import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  File? _dbFile;
  Map<String, dynamic> _db = {'users': []};

  Future<void> init() async {
    try {
      if (kIsWeb) {
        // Sem persistência em web neste estágio; fallback em memória.
        if (kDebugMode && (_db['users'] as List).isEmpty) {
          await register('admin@example.com', 'admin', 'admin123');
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}${Platform.pathSeparator}auth_db.json';
      _dbFile = File(path);
      if (await _dbFile!.exists()) {
        final content = await _dbFile!.readAsString();
        _db = jsonDecode(content) as Map<String, dynamic>;
      } else {
        await _persist();
      }
      if (kDebugMode) {
        if ((_db['users'] as List).isEmpty) {
          await register('admin@example.com', 'admin', 'admin123');
        }
      }
    } catch (e) {
      // Fallback: mantém apenas em memória.
      if (kDebugMode) {
        // ignore: avoid_print
        print('AuthService init fallback (mem-only): $e');
      }
      if (kDebugMode && (_db['users'] as List).isEmpty) {
        await register('admin@example.com', 'admin', 'admin123');
      }
    }
  }

  Future<void> _persist() async {
    if (_dbFile == null) return;
    await _dbFile!.writeAsString(jsonEncode(_db), flush: true);
  }

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  Future<bool> register(String email, String username, String password) async {
    final users = List<Map<String, dynamic>>.from(_db['users'] as List);
    final exists = users.any(
      (u) => u['email'] == email || u['username'] == username,
    );
    if (exists) return false;
    users.add({
      'email': email,
      'username': username,
      'passwordHash': _hash(password),
      'createdAt': DateTime.now().toIso8601String(),
    });
    _db['users'] = users;
    await _persist();
    return true;
  }

  Future<bool> login(String userOrEmail, String password) async {
    final users = List<Map<String, dynamic>>.from(_db['users'] as List);
    final hash = _hash(password);
    final ok = users.any(
      (u) =>
          (u['email'] == userOrEmail || u['username'] == userOrEmail) &&
          u['passwordHash'] == hash,
    );
    return ok;
  }

  Future<List<Map<String, dynamic>>> listUsers() async {
    return List<Map<String, dynamic>>.from(_db['users'] as List);
  }
}

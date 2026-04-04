import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  static const _keyPrefKey = 'encryption_device_key';
  encrypt.Key? _key;
  final _iv = encrypt.IV.fromLength(16);

  /// Initialize with a device-unique key derived from first-launch UUID.
  /// This is stored in SharedPreferences and persists across app launches.
  /// For full production, derive from user password via PBKDF2.
  Future<void> initialize() async {
    if (_key != null) return;
    final prefs = await SharedPreferences.getInstance();
    var storedKey = prefs.getString(_keyPrefKey);
    if (storedKey == null) {
      // Generate a unique 32-byte key on first launch
      storedKey = const Uuid().v4().replaceAll('-', '');
      await prefs.setString(_keyPrefKey, storedKey);
    }
    _key = encrypt.Key.fromUtf8(storedKey);
  }

  encrypt.Key get _safeKey {
    if (_key == null) {
      // Fallback if not initialized (should not happen in normal flow)
      _key = encrypt.Key.fromUtf8('1984_NEON_GRID_MAINFRAME_KEY_XYZ');
    }
    return _key!;
  }

  String encryptData(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_safeKey));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptData(String encryptedBase64) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_safeKey));
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: _iv);
    return decrypted;
  }

  Uint8List encryptBytes(Uint8List data) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_safeKey));
    final encrypted = encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  Uint8List decryptBytes(Uint8List encryptedData) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_safeKey));
    final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedData), iv: _iv);
    return Uint8List.fromList(decrypted);
  }
}

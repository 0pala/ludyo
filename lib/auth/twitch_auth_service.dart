import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TwitchAuthService {
  static const _clientId = String.fromEnvironment('TWITCH_CLIENT_ID');
  static const _clientSecret = String.fromEnvironment('TWITCH_CLIENT_SECRET');
  static const _tokenUrl = 'https://id.twitch.tv/oauth2/token';
  final _storage = const FlutterSecureStorage();

  Future<String> getAccessToken() async {
    final savedToken = await _storage.read(key: 'igdb_token');
    final expiry = await _storage.read(key: 'igdb_token_expiry');

    if (savedToken != null && expiry != null) {
      final expireAst = DateTime.parse(expiry);
      if (DateTime.now().isBefore(expireAst)) {
        return savedToken;
      }
    }

    final response = await http.post(
      Uri.parse(_tokenUrl),
      body: {'client_id': _clientId, 'client_secret': _clientSecret, 'grant_type': 'client_credentials'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error: OAuth Twitch not valid');
    }

    final data = jsonDecode(response.body);

    final token = data['access_token'];
    final expiresIn = data['expires_in'];

    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await _storage.write(key: 'igdb_token', value: token);
    await _storage.write(key: 'igdb_token_expiry', value: expiresAt.toIso8601String());

    return token;
  }
}

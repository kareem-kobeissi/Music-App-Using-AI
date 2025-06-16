import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';


//The x-auth-token is a common header used in HTTP requests to represent an authentication token
@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref) {
  return AuthLocalRepository();
}

/// This class is responsible for managing the local storage of authentication tokens using SharedPreferences.
///  It is used to store simple key-value pairs persistently on the device. In this case, it's storing the authentication token.
class AuthLocalRepository {
  SharedPreferences? _sharedPreferences;

  /// This method initializes the SharedPreferences instance.
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// This method sets the authentication token in local storage.
  /// It takes a [token] as a parameter and stores it in SharedPreferences under the key 'x-auth-token'.
  void setToken(String? token) {
    if (token != null) {
      _sharedPreferences?.setString('x-auth-token', token);

    }

  }

  /// This method retrieves the authentication token from local storage.
  /// It returns the token as a [String?]. If the token is not found, it returns null.
  String? getToken() {
    return _sharedPreferences?.getString('x-auth-token');
  }
}

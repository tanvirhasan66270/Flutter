class AuthService {

  final String baseUrl = "http://localhost:8085/api/auth";

  Future<bool> login(String email, String password) async {

    final url = Uri.parse('$baseUrl/login');

    return true;
  }

}
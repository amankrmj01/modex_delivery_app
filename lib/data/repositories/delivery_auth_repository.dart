class DeliveryAuthRepository {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'delivery@test.com' && password == 'password') {
      return 'delivery_partner_123';
    } else {
      throw Exception('Invalid partner credentials.');
    }
  }
}

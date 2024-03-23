import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<List<dynamic>> getUsers(int page) async {
    try {
      final response = await _dio.get('https://reqres.in/api/users', queryParameters: {'page': page});
      final data = response.data['data'];
      // print("aaaaa $data");
      return data; // Returns a list of user data
    } catch (e) {
      throw Exception('Failed to fetch users');
    }
  }
}

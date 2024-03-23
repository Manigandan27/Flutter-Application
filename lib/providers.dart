import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'user_model.dart'; // Import the User model class


// Define usersProvider
final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final apiService = ApiService(dio);
  final data = await apiService.getUsers(1); 
  return data.map((userData) => UserModel.fromJson(userData)).toList();
  
});

// Provide Dio instance as a dependency
final dioProvider = Provider<Dio>((ref) => Dio());

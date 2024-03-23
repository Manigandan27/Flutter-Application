import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart'; // Import the file where usersProvider is defined

class SecondScreen extends ConsumerWidget {
  final String address;
  final double latitude;
  final double longitude;

  const SecondScreen({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Details'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display address details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address: $address',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Latitude: $latitude',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Longitude: $longitude',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: usersAsyncValue.when(
                // Handle different states of the FutureProvider
                data: (users) {
                  debugPrint('Number of users: ${users.length}');
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final firstName = user.firstName ?? 'Unknown';
                      final lastName = user.lastName ?? 'Unknown';
                      final email = user.email ?? 'Unknown';
                      final avatar = user.avatar ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                        ),
                        title: Text('$firstName $lastName'),
                        subtitle: Text(email),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

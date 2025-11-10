import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final response = await Supabase.instance.client
        .from('score') // Changed from 'leaderboard' to 'score'
        .select()
        .order(
          'disparos',
          ascending: true,
        ) // Changed from 'score' to 'disparos'
        .limit(10);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scores yet.'));
          }

          final scores = snapshot.data!;
          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              return ListTile(
                leading: Text('${index + 1}.'),
                title: Text(
                  score['nombre_player'] ?? 'Anonymous',
                ), // Changed from 'name' to 'nombre_player'
                trailing: Text(
                  '${score['disparos'] ?? 0}',
                ), // Changed from 'score' to 'disparos'
              );
            },
          );
        },
      ),
    );
  }
}

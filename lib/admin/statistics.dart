import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsReportsScreen extends StatefulWidget {
  const StatisticsReportsScreen({super.key});

  @override
  _StatisticsReportsScreenState createState() => _StatisticsReportsScreenState();
}

class _StatisticsReportsScreenState extends State<StatisticsReportsScreen> {
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _fetchStatistics();
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    Map<String, dynamic> statistics = {};
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    QuerySnapshot<Map<String, dynamic>> meetingSnapshot = await FirebaseFirestore.instance.collection('meetings').get();

    int loggedInUsers = 0;
    int totalUsers = userSnapshot.docs.length;
    int totalMeetings = meetingSnapshot.docs.length;

    for (var doc in userSnapshot.docs) {
      bool isLoggedIn = doc.data()['is_logged_in'] ?? false;
      if (isLoggedIn) {
        loggedInUsers++;
      }
    }

    statistics['loggedInUsers'] = loggedInUsers;
    statistics['totalUsers'] = totalUsers;
    statistics['totalMeetings'] = totalMeetings;

    return statistics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Reports'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            Map<String, dynamic> data = snapshot.data!;
            int loggedInUsers = data['loggedInUsers'];
            int totalUsers = data['totalUsers'];
            int totalMeetings = data['totalMeetings'];

            return ListView(
              children: [
                _buildStatisticTile('Total Users', totalUsers),
                _buildStatisticTile('Logged In Users', loggedInUsers),
                _buildStatisticTile('Total Meetings', totalMeetings),
                const SizedBox(height: 20),
                _buildUserPieChart(loggedInUsers, totalUsers - loggedInUsers),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticTile(String title, int count) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      trailing: Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUserPieChart(int loggedInUsers, int loggedOutUsers) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: loggedInUsers.toDouble(),
              color: Colors.blueAccent,
              title: 'Logged In\n$loggedInUsers',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: loggedOutUsers.toDouble(),
              color: Colors.orangeAccent,
              title: 'Logged Out\n$loggedOutUsers',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

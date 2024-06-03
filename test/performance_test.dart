import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Server response time is less than 1 second', () async {
    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse('https://your-api-endpoint.com'));
    stopwatch.stop();

    final responseTime = stopwatch.elapsedMilliseconds;
    print('Server response time: $responseTime ms');

    expect(response.statusCode, 200);
    expect(responseTime, lessThan(1000)); // Czas odpowiedzi serwera nie dłuższy niż 1 sekunda
  });
}

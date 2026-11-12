import 'package:integration_test/integration_test_driver.dart';

/// Host side of `flutter drive`: writes the test's report data (frame
/// timings) to build/integration_response_data.json.
Future<void> main() => integrationDriver();

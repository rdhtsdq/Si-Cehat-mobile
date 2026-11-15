import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/core/api/api_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('custom base URL persists under a stable key and is restored by init()',
      () async {
    SharedPreferences.setMockInitialValues({});
    await ApiConstants.setCustomBaseUrl('http://192.168.1.10:3000');

    final prefs = await SharedPreferences.getInstance();
    // Regression: the value must be stored under a proper pref key, not under
    // the URL itself (the old bug used the URL string as the key).
    expect(prefs.getString('api_base_url'), 'http://192.168.1.10:3000');
    expect(prefs.getString('http://192.168.1.10:3000'), isNull);

    // Simulate a fresh process: forget in-memory state but keep what a previous
    // run would have left in prefs, then re-init.
    await ApiConstants.setCustomBaseUrl(null);
    await prefs.setString('api_base_url', 'http://192.168.1.10:3000');
    await ApiConstants.init();

    expect(ApiConstants.baseUrl, 'http://192.168.1.10:3000');
  });

  test('clearing the custom URL falls back to production', () async {
    SharedPreferences.setMockInitialValues({});
    await ApiConstants.setCustomBaseUrl('http://192.168.1.10:3000');
    await ApiConstants.setCustomBaseUrl(null);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('api_base_url'), isNull);
    expect(ApiConstants.baseUrl, ApiConstants.productionUrl);
  });
}

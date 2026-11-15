import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/providers/app_providers.dart';
import 'package:si_cehat_mobile/screens/community/community_screen.dart';

/// A CommunityProvider that never touches the network, so the widget test is
/// deterministic and does not depend on SharedPreferences/HTTP.
class _FakeCommunityProvider extends CommunityProvider {
  @override
  Future<void> loadFeed({bool refresh = false}) async {
    // Intentionally empty: leaves the feed in its initial empty state.
  }
}

void main() {
  testWidgets(
    'CommunityScreen renders tabs, empty state, and create CTA',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityProvider.overrideWith((ref) => _FakeCommunityProvider()),
          ],
          child: const MaterialApp(home: CommunityScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Komunitas'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Populer'), findsOneWidget);
      expect(find.text('Saya'), findsOneWidget);
      expect(find.text('+ Buat Postingan'), findsOneWidget);
      expect(
        find.text('Belum ada postingan. Jadilah yang pertama berbagi tips!'),
        findsOneWidget,
      );
    },
  );
}

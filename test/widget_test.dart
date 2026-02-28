import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App shows personalized news shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'news_user_tags': <String>['technology'],
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('User Friendly News'), findsOneWidget);
    expect(find.text('Your tags'), findsOneWidget);
  });
}

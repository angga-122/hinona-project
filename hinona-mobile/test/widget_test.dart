
import 'package:flutter_test/flutter_test.dart';
import 'package:hinona_mobile/main.dart';

void main() {
  testWidgets('HinonaApp berhasil ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const HinonaApp());

    expect(find.text('Hinona Coffee & Roastery'), findsOneWidget);
  });
}

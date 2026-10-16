import 'package:flutter_test/flutter_test.dart';
import 'package:long_ky_game/app/long_ky_app.dart';

void main() {
  testWidgets('title screen shows the product name', (tester) async {
    await tester.pumpWidget(const LongKyApp());
    expect(find.text(LongKyApp.productName), findsOneWidget);
  });
}

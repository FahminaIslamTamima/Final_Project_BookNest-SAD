
import 'package:flutter_test/flutter_test.dart';
import 'package:booknest/main.dart';

void main() {
  testWidgets('BookNest app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BookNestApp());

    await tester.pumpAndSettle();

    expect(find.text('BookNest'), findsOneWidget);
    expect(find.text('Your Personal Reading Companion'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}



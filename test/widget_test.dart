import 'package:flutter_application_1/logic/cubits/auth_cubit.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    final authCubit = AuthCubit();

    await tester.pumpWidget(SmartMeteoApp(
      isLoggedIn: true,
      authCubit: authCubit,
    ));


    expect(find.text('Smart meteostation'), findsOneWidget);
  });
}

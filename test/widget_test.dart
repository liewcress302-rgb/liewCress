import 'package:flutter_test/flutter_test.dart';

import 'package:simple_shop/main.dart';

void main() {
  testWidgets('shop app shows home content', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopApp());

    expect(find.text('简易购物系统'), findsOneWidget);
    expect(find.text('欢迎来到掌上小店'), findsOneWidget);
    expect(find.text('推荐商品'), findsOneWidget);
    expect(find.text('无线耳机'), findsOneWidget);
  });
}

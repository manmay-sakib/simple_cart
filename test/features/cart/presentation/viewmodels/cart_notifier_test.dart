import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';
import 'package:simple_cart/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:simple_cart/features/product/domain/models/product_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

final testProduct1 = ProductModel(
  id: 1,
  title: 'Test Product 1',
  price: 10.0,
  description: '',
  category: '',
  image: '',
);

final testProduct2 = ProductModel(
  id: 2,
  title: 'Test Product 2',
  price: 20.0,
  description: '',
  category: '',
  image: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  setUp(() {
    mockPrefs = MockSharedPreferences();

    container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWith((ref) async => mockPrefs)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier', () {
    test('initial state is empty and loads from SharedPreferences', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);

      final cartNotifier = container.read(cartProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(cartNotifier.state.items, isEmpty);
      verify(() => mockPrefs.getString('cart')).called(1);
    });

    test('addToCart adds a new product', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);

      expect(cartNotifier.state.items, containsPair(testProduct1, 1));
      verify(() => mockPrefs.setString('cart', any())).called(1);
    });

    test('addToCart increments quantity of existing product', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);
      await cartNotifier.addToCart(testProduct1);

      expect(cartNotifier.state.items, containsPair(testProduct1, 2));
      verify(() => mockPrefs.setString('cart', any())).called(2);
    });

    test('decreaseQuantity decreases product count', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);
      await cartNotifier.addToCart(testProduct1);

      await cartNotifier.decreaseQuantity(testProduct1);

      expect(cartNotifier.state.items, containsPair(testProduct1, 1));
      verify(() => mockPrefs.setString('cart', any())).called(3);
    });

    test('decreaseQuantity removes product if count is 1', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);

      await cartNotifier.decreaseQuantity(testProduct1);

      expect(cartNotifier.state.items, isEmpty);
      verify(() => mockPrefs.setString('cart', any())).called(2);
    });

    test('removeFromCart removes product entirely', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);
      await cartNotifier.addToCart(testProduct2);

      await cartNotifier.removeFromCart(testProduct1);

      expect(cartNotifier.state.items, isNot(contains(testProduct1)));
      expect(cartNotifier.state.items, containsPair(testProduct2, 1));
      verify(() => mockPrefs.setString('cart', any())).called(3);
    });

    test('clearCart empties the cart', () async {
      when(() => mockPrefs.getString('cart')).thenReturn(null);
      when(
        () => mockPrefs.setString('cart', any()),
      ).thenAnswer((_) async => true);

      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(testProduct1);
      await cartNotifier.addToCart(testProduct2);

      await cartNotifier.clearCart();

      expect(cartNotifier.state.items, isEmpty);
      verify(() => mockPrefs.setString('cart', any())).called(3);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_cart/features/product/domain/models/product_model.dart';
import 'package:simple_cart/features/product/presentation/viewmodels/product_list_viewmodel.dart';
import 'package:simple_cart/core/providers/shared_prefs_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;
  late ProductModel product;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    container = ProviderContainer(
      overrides: [
        // Override the future provider with a future returning mockPrefs
        sharedPrefsProvider.overrideWith((ref) => Future.value(mockPrefs)),
      ],
    );

    // Dummy product
    product = ProductModel(
      id: 1,
      title: 'Test Product',
      price: 10.0,
      description: '',
      category: '',
      image: '',
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('toggleFavorite adds and removes product from favorites', () async {
    // Arrange: SharedPreferences returns empty list initially
    when(() => mockPrefs.getStringList('favorite_ids')).thenReturn([]);
    when(
      () => mockPrefs.setStringList(any(), any()),
    ).thenAnswer((_) async => true);

    // Create and initialize the ProductListViewmodel
    final notifier = container.read(productListViewmodelProvider.notifier);

    // Mock initial state with one product
    await notifier
        .initializeState([product], mockPrefs)
        .then((state) => notifier.state = AsyncData(state));

    // Act: Toggle favorite ON
    await notifier.toggleFavorite(product);

    // Assert: Product is marked favorite in state
    final currentState = notifier.state.asData!.value;
    expect(currentState.products.first.isFavorite, true);

    // Verify SharedPreferences was updated
    verify(() => mockPrefs.setStringList('favorite_ids', ['1'])).called(1);

    // Act: Toggle favorite OFF
    await notifier.toggleFavorite(product);

    // Assert: Product is not favorite in state
    final updatedState = notifier.state.asData!.value;
    expect(updatedState.products.first.isFavorite, false);

    // Verify SharedPreferences updated again
    verify(() => mockPrefs.setStringList('favorite_ids', [])).called(1);
  });
}

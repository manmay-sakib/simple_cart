import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_cart/core/errors/failure.dart';
import 'package:simple_cart/features/product/data/entities/product_response.dart';
import 'package:simple_cart/features/product/data/repositories/product_repository_impl.dart';
import 'package:simple_cart/features/product/data/services/product_service.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService mockService;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockService = MockProductService();
    repository = ProductRepositoryImpl(mockService);
  });

  group('ProductRepositoryImpl.fetchProducts', () {
    final productResponseList = [
      ProductResponse(
        id: 1,
        title: 'Test Product 1',
        price: 10.0,
        description: 'Desc 1',
        category: 'Cat 1',
        image: 'image1.png',
      ),
      ProductResponse(
        id: 2,
        title: 'Test Product 2',
        price: 20.0,
        description: 'Desc 2',
        category: 'Cat 2',
        image: 'image2.png',
      ),
    ];

    test('returns list of ProductModel on success', () async {
      when(
        () => mockService.getProducts(),
      ).thenAnswer((_) async => productResponseList);

      final result = await repository.fetchProducts();

      result.match(
        (failure) => fail('Expected success, got failure: ${failure.message}'),
        (products) {
          expect(products.length, 2);
          expect(products[0].id, 1);
          expect(products[1].id, 2);
        },
      );

      verify(() => mockService.getProducts()).called(1);
    });

    test('returns Failure when service throws', () async {
      when(
        () => mockService.getProducts(),
      ).thenThrow(Exception('Network error'));

      final result = await repository.fetchProducts();

      result.match((failure) {
        expect(failure, isA<Failure>());
        expect(failure.message, contains('Network error'));
      }, (_) => fail('Expected failure, got success'));

      verify(() => mockService.getProducts()).called(1);
    });

    test('returns Failure when service returns empty list', () async {
      when(() => mockService.getProducts()).thenAnswer((_) async => []);

      final result = await repository.fetchProducts();

      result.match((failure) {
        expect(failure, isA<Failure>());
        expect(
          failure.message,
          contains('Something went wrong on Fetching product list'),
        );
      }, (_) => fail('Expected failure, got success'));

      verify(() => mockService.getProducts()).called(1);
    });
  });

  group('ProductRepositoryImpl.fetchProductById', () {
    final productResponse = ProductResponse(
      id: 1,
      title: 'Test Product',
      price: 15.0,
      description: 'Desc',
      category: 'Cat',
      image: 'image.png',
    );

    test('returns ProductModel on success', () async {
      when(
        () => mockService.getProductById(1),
      ).thenAnswer((_) async => productResponse);

      final result = await repository.fetchProductById(1);

      result.match(
        (failure) => fail('Expected success, got failure: ${failure.message}'),
        (product) {
          expect(product.id, 1);
          expect(product.title, 'Test Product');
        },
      );

      verify(() => mockService.getProductById(1)).called(1);
    });

    test('returns Failure when service throws', () async {
      when(
        () => mockService.getProductById(1),
      ).thenThrow(Exception('Network error'));

      final result = await repository.fetchProductById(1);

      result.match((failure) {
        expect(failure, isA<Failure>());
        expect(failure.message, contains('Network error'));
      }, (_) => fail('Expected failure, got success'));

      verify(() => mockService.getProductById(1)).called(1);
    });

    test('returns Failure when returned product id does not match', () async {
      when(() => mockService.getProductById(1)).thenAnswer(
        (_) async => ProductResponse(
          id: 999,
          title: 'Wrong Product',
          price: 0,
          description: '',
          category: '',
          image: '',
        ),
      );

      final result = await repository.fetchProductById(1);

      result.match((failure) {
        expect(failure, isA<Failure>());
        expect(failure.message, contains('Something went wrong'));
      }, (_) => fail('Expected failure, got success'));

      verify(() => mockService.getProductById(1)).called(1);
    });
  });
}

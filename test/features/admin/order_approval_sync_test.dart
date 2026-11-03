import 'package:dio/dio.dart';
import 'package:final_project/core/network/api_client.dart';
import 'package:final_project/core/storage/local_storage.dart';
import 'package:final_project/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:final_project/features/admin/domain/entities/admin_models.dart';
import 'package:final_project/features/orders/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient mockApiClient;
  late MockLocalStorage mockLocalStorage;
  late AdminRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocalStorage = MockLocalStorage();

    when(() => mockLocalStorage.getAccessToken()).thenReturn(null);
    when(() => mockApiClient.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/offline')),
    );
    when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/offline')),
    );
    when(() => mockApiClient.patch(
          any(),
          data: any(named: 'data'),
        )).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/offline')),
    );

    dataSource = AdminRemoteDataSource(
      apiClient: mockApiClient,
      localStorage: mockLocalStorage,
    );
  });

  group('Customer Order Approval & Sync (order_process.md Steps 1–17)', () {
    test(
      'Step 1–8: placing customer order creates pending order and deducts ProductVariant stock',
      () async {
        // Register a product with a variant having 10 units in stock
        const product = AdminProduct(
          id: 'prd-sync-test-1',
          storeId: 'str-000005',
          storeName: 'Kutuku Official',
          categoryId: 'cat-000001',
          categoryName: 'Apparel',
          name: 'SETEC Hoodie',
          slug: 'setec-hoodie',
          sku: 'HOODIE-NVY-L',
          description: 'Official hoodie',
          basePrice: 30.0,
          stockQuantity: 10,
          variants: [
            AdminProductVariant(
              id: 'var-sync-test-1',
              productId: 'prd-sync-test-1',
              sku: 'HOODIE-NVY-L',
              name: 'Navy / L',
              price: 30.0,
              stockQuantity: 10,
              status: 'active',
            ),
          ],
        );
        AdminRemoteDataSource.registerExternalProduct(product);

        final createdOrder = await dataSource.placeCustomerOrderAndSync(
          productId: 'prd-sync-test-1',
          variantId: 'var-sync-test-1',
          quantity: 3,
          customerName: 'Dara Test',
          customerPhone: '+855 12 999 888',
          autoPayAndConfirm: false,
        );

        expect(createdOrder.status, OrderStatus.pending);
        expect(createdOrder.payment?.status, PaymentStatus.pending);
        expect(createdOrder.totalAmount, 90.0);

        // Verify variant stock decreased from 10 -> 7 (Step 6)
        final products = await dataSource.getAdminProducts();
        final syncedProd =
            products.firstWhere((p) => p.id == 'prd-sync-test-1');
        expect(syncedProd.stockQuantity, 7);
        expect(syncedProd.variants.first.stockQuantity, 7);
      },
    );

    test(
      'Step 8–10: approving pending customer order transitions to confirmed (or processing) and marks payment succeeded',
      () async {
        final createdOrder = await dataSource.placeCustomerOrderAndSync(
          quantity: 1,
          customerName: 'Sophea Approval',
          autoPayAndConfirm: false,
        );
        expect(createdOrder.status, OrderStatus.pending);

        // Step 9: Admin approves order (`pending` -> `confirmed`)
        final approvedOrder = await dataSource.approveCustomerOrder(
          createdOrder.id,
          note: 'Approved by Admin in unit test',
          autoStartPreparing: false,
        );

        expect(approvedOrder.status, OrderStatus.confirmed);
        expect(approvedOrder.payment?.status, PaymentStatus.succeeded);
        expect(
          approvedOrder.statusHistory?.last.toStatus,
          OrderStatus.confirmed,
        );

        // Step 10: Start preparing (`confirmed` -> `processing`)
        final processingOrder = await dataSource.startOrderPreparing(
          createdOrder.id,
        );
        expect(processingOrder.status, OrderStatus.processing);
      },
    );

    test(
      'Cancellation Flow: cancelling an active order restores ProductVariant stock and refunds payment',
      () async {
        const product = AdminProduct(
          id: 'prd-cancel-test',
          storeId: 'str-000005',
          storeName: 'Kutuku Official',
          categoryId: 'cat-000001',
          categoryName: 'Footwear',
          name: 'Limited Sneaker',
          slug: 'limited-sneaker',
          sku: 'SNK-LTD-42',
          description: 'Limited edition',
          basePrice: 50.0,
          stockQuantity: 2,
          variants: [
            AdminProductVariant(
              id: 'var-cancel-test',
              productId: 'prd-cancel-test',
              sku: 'SNK-LTD-42',
              name: 'Size 42',
              price: 50.0,
              stockQuantity: 2,
              status: 'active',
            ),
          ],
        );
        AdminRemoteDataSource.registerExternalProduct(product);

        // Order all 2 units -> variant stock becomes 0 (`out_of_stock`)
        final placed = await dataSource.placeCustomerOrderAndSync(
          productId: 'prd-cancel-test',
          variantId: 'var-cancel-test',
          quantity: 2,
          autoPayAndConfirm: true,
        );
        expect(placed.status, OrderStatus.confirmed);
        expect(placed.payment?.status, PaymentStatus.succeeded);

        var products = await dataSource.getAdminProducts();
        var prodAfterOrder =
            products.firstWhere((p) => p.id == 'prd-cancel-test');
        expect(prodAfterOrder.variants.first.stockQuantity, 0);
        expect(prodAfterOrder.variants.first.status, 'out_of_stock');

        // Admin cancels the order -> variant stock restored to 2 (`active`) & payment `refunded`
        final cancelled = await dataSource.cancelAdminOrder(
          placed.id,
          note: 'Cancelled in test',
        );
        expect(cancelled.status, OrderStatus.cancelled);
        expect(cancelled.payment?.status, PaymentStatus.refunded);

        products = await dataSource.getAdminProducts();
        prodAfterOrder = products.firstWhere((p) => p.id == 'prd-cancel-test');
        expect(prodAfterOrder.variants.first.stockQuantity, 2);
        expect(prodAfterOrder.variants.first.status, 'active');
      },
    );
  });
}

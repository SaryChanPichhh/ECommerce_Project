import os

base_dir = r'E:\SETEC INSTITUTE\Semester IIV\MA\final_project'

files_to_create = {
    r'lib\app\routes\app_routes.dart': '''/// Centralized route name constants.
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/edit';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String customerCreate = '/customers/create';
  static const String customerEdit = '/customers/edit';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
}
''',
    r'lib\app\routes\app_pages.dart': '''import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/bindings/product_binding.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_form_page.dart';
import '../../features/customers/presentation/bindings/customer_binding.dart';
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/orders/presentation/bindings/order_binding.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/bindings/profile_binding.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'app_routes.dart';

/// Application pages configuration.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = <GetPage>[
    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

    // Products
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productCreate,
      page: () => const ProductFormPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productEdit,
      page: () => const ProductFormPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductBinding(),
    ),

    // Customers
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerListPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerCreate,
      page: () => const CustomerFormPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerEdit,
      page: () => const CustomerFormPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerDetail,
      page: () => const CustomerDetailPage(),
      binding: CustomerBinding(),
    ),

    // Orders
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailPage(),
      binding: OrderBinding(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
  ];
}
''',
    r'lib\app\bindings\initial_binding.dart': '''import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/network/interceptors/logging_interceptor.dart';
import '../../core/storage/local_storage.dart';

/// Initial binding that sets up global dependencies.
/// These are created once at app startup and available everywhere.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Local Storage — singleton
    Get.put(LocalStorage(), permanent: true);

    // API Client — singleton
    final apiClient = ApiClient();
    apiClient.addInterceptors([
      AuthInterceptor(localStorage: Get.find<LocalStorage>()),
      LoggingInterceptor(),
    ]);
    Get.put(apiClient, permanent: true);
  }
}
''',
    r'lib\app\app.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Initial binding
      initialBinding: InitialBinding(),

      // Default transition
      defaultTransition: Transition.cupertino,
    );
  }
}
''',
    r'lib\main.dart': '''import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await GetStorage.init();

  runApp(const App());
}
''',
    r'lib\features\home\presentation\controllers\home_controller.dart': '''import 'package:get/get.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/utils/helpers.dart';

/// Controller for the home/dashboard page.
class HomeController extends GetxController {
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  HomeController({
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      currentUser.value = await _getCurrentUserUseCase();
    } catch (_) {
      // Silently handle — user may continue without user data
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );
    if (!confirmed) return;

    try {
      await _logoutUseCase();
      Get.offAllNamed('/login');
    } catch (e) {
      Helpers.showError('Failed to logout');
    }
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }
}
''',
    r'lib\features\home\presentation\bindings\home_binding.dart': '''import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../controllers/home_controller.dart';

/// Binding for the home feature.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Auth dependencies needed by Home
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(localStorage: Get.find<LocalStorage>()),
    );
    Get.lazyPut(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );
    Get.lazyPut(
      () => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut(
      () => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()),
    );

    // Home controller
    Get.lazyPut(
      () => HomeController(
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );
  }
}
''',
    r'lib\features\home\presentation\pages\home_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../controllers/home_controller.dart';

/// Main dashboard/home page.
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Obx(() {
              final user = controller.currentUser.value;
              return Text(
                'Welcome${user != null ? ", ${user.name}" : ""}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              );
            }),
            const SizedBox(height: AppDimensions.lg),

            // Quick access cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimensions.md,
              crossAxisSpacing: AppDimensions.md,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  onTap: () => Get.toNamed('/products'),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Customers',
                  icon: Icons.people_outline,
                  color: AppColors.secondary,
                  onTap: () => Get.toNamed('/customers'),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Orders',
                  icon: Icons.shopping_cart_outlined,
                  color: AppColors.accent,
                  onTap: () => Get.toNamed('/orders'),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Profile',
                  icon: Icons.person_outline,
                  color: AppColors.success,
                  onTap: () => Get.toNamed('/profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''',
    r'lib\features\customers\domain\entities\customer.dart': '''class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? company;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.company,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Customer && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
''',
    r'lib\features\customers\domain\repositories\customer_repository.dart': '''import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({int? page, int? limit, String? search});
  Future<Customer> getCustomer(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
''',
    r'lib\features\customers\domain\usecases\get_customers.dart': '''import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repository;
  GetCustomersUseCase({required CustomerRepository repository})
      : _repository = repository;

  Future<List<Customer>> call({int? page, int? limit, String? search}) {
    return _repository.getCustomers(page: page, limit: limit, search: search);
  }
}
''',
    r'lib\features\customers\domain\usecases\get_customer.dart': '''import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerUseCase {
  final CustomerRepository _repository;
  GetCustomerUseCase({required CustomerRepository repository})
      : _repository = repository;

  Future<Customer> call(String id) => _repository.getCustomer(id);
}
''',
    r'lib\features\customers\domain\usecases\create_customer.dart': '''import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;
  CreateCustomerUseCase({required CustomerRepository repository})
      : _repository = repository;

  Future<Customer> call(Customer customer) => _repository.createCustomer(customer);
}
''',
    r'lib\features\customers\domain\usecases\update_customer.dart': '''import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository _repository;
  UpdateCustomerUseCase({required CustomerRepository repository})
      : _repository = repository;

  Future<Customer> call(Customer customer) => _repository.updateCustomer(customer);
}
''',
    r'lib\features\customers\domain\usecases\delete_customer.dart': '''import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository _repository;
  DeleteCustomerUseCase({required CustomerRepository repository})
      : _repository = repository;

  Future<void> call(String id) => _repository.deleteCustomer(id);
}
''',
    r'lib\features\customers\data\models\customer_model.dart': '''import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.address,
    super.company,
    super.createdAt,
    super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      company: json['company'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'company': company,
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
      company: customer.company,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }
}
''',
    r'lib\features\customers\data\datasources\customer_remote_datasource.dart': '''import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({int? page, int? limit, String? search});
  Future<CustomerModel> getCustomer(String id);
  Future<CustomerModel> createCustomer(Map<String, dynamic> data);
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data);
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CustomerModel>> getCustomers({int? page, int? limit, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get('/customers', queryParameters: queryParams);
    final data = response.data;
    List<dynamic> items;
    if (data is Map<String, dynamic>) {
      items = data['data'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CustomerModel> getCustomer(String id) async {
    final response = await _apiClient.get('/customers/$id');
    final data = response.data;
    final customerData = data is Map<String, dynamic> && data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return CustomerModel.fromJson(customerData);
  }

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/customers', data: data);
    final responseData = response.data;
    final customerData = responseData is Map<String, dynamic> && responseData.containsKey('data')
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;
    return CustomerModel.fromJson(customerData);
  }

  @override
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/customers/$id', data: data);
    final responseData = response.data;
    final customerData = responseData is Map<String, dynamic> && responseData.containsKey('data')
        ? responseData['data'] as Map<String, dynamic>
        : responseData as Map<String, dynamic>;
    return CustomerModel.fromJson(customerData);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _apiClient.delete('/customers/$id');
  }
}
''',
    r'lib\features\customers\data\repositories\customer_repository_impl.dart': '''import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepositoryImpl({required CustomerRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Customer>> getCustomers({int? page, int? limit, String? search}) async {
    try {
      return await _remoteDataSource.getCustomers(page: page, limit: limit, search: search);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Customer> getCustomer(String id) async {
    try {
      return await _remoteDataSource.getCustomer(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Customer not found');
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      return await _remoteDataSource.createCustomer(model.toJson());
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      return await _remoteDataSource.updateCustomer(customer.id, model.toJson());
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Customer not found');
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _remoteDataSource.deleteCustomer(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Customer not found');
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
''',
    r'lib\features\customers\presentation\controllers\customer_controller.dart': '''import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/delete_customer.dart';

class CustomerController extends GetxController {
  final GetCustomersUseCase _getCustomersUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;

  CustomerController({
    required GetCustomersUseCase getCustomersUseCase,
    required DeleteCustomerUseCase deleteCustomerUseCase,
  })  : _getCustomersUseCase = getCustomersUseCase,
        _deleteCustomerUseCase = deleteCustomerUseCase;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _getCustomersUseCase(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
      customers.assignAll(result);
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    final confirmed = await AppDialog.showConfirm(
      title: 'Delete Customer',
      message: 'Are you sure you want to delete this customer?',
      confirmText: 'Delete',
      isDanger: true,
    );
    if (!confirmed) return;

    try {
      await _deleteCustomerUseCase(id);
      customers.removeWhere((c) => c.id == id);
      Helpers.showSuccess('Customer deleted successfully');
    } on Failure catch (e) {
      Helpers.showError(e.message);
    } catch (e) {
      Helpers.showError('Failed to delete customer');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchCustomers();
  }

  Future<void> refreshCustomers() => fetchCustomers();
}
''',
    r'lib\features\customers\presentation\controllers\customer_form_controller.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/get_customer.dart';

class CustomerFormController extends GetxController {
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final GetCustomerUseCase _getCustomerUseCase;

  CustomerFormController({
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateCustomerUseCase updateCustomerUseCase,
    required GetCustomerUseCase getCustomerUseCase,
  })  : _createCustomerUseCase = createCustomerUseCase,
        _updateCustomerUseCase = updateCustomerUseCase,
        _getCustomerUseCase = getCustomerUseCase;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Customer> customer = Rxn<Customer>();

  bool get isEditing => customer.value != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) {
      loadCustomer(args);
    }
  }

  Future<void> loadCustomer(String id) async {
    isLoading.value = true;
    try {
      final result = await _getCustomerUseCase(id);
      customer.value = result;
      nameController.text = result.name;
      emailController.text = result.email ?? '';
      phoneController.text = result.phone ?? '';
      addressController.text = result.address ?? '';
      companyController.text = result.company ?? '';
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load customer';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCustomer() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final customerData = Customer(
        id: customer.value?.id ?? '',
        name: nameController.text.trim(),
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        company: companyController.text.trim().isNotEmpty ? companyController.text.trim() : null,
      );

      if (isEditing) {
        await _updateCustomerUseCase(customerData);
        Helpers.showSuccess('Customer updated successfully');
      } else {
        await _createCustomerUseCase(customerData);
        Helpers.showSuccess('Customer created successfully');
      }

      Get.back(result: true);
    } on Failure catch (e) {
      errorMessage.value = e.message;
      Helpers.showError(e.message);
    } catch (e) {
      errorMessage.value = 'Failed to save customer';
      Helpers.showError('Failed to save customer');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    companyController.dispose();
    super.onClose();
  }
}
''',
    r'lib\features\customers\presentation\bindings\customer_binding.dart': '''import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/get_customer.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../controllers/customer_controller.dart';
import '../controllers/customer_form_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut(
      () => CustomerRepositoryImpl(
        remoteDataSource: Get.find<CustomerRemoteDataSource>(),
      ),
    );
    Get.lazyPut(() => GetCustomersUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => GetCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => CreateCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => UpdateCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => DeleteCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));

    Get.lazyPut(() => CustomerController(
      getCustomersUseCase: Get.find<GetCustomersUseCase>(),
      deleteCustomerUseCase: Get.find<DeleteCustomerUseCase>(),
    ));
    Get.lazyPut(() => CustomerFormController(
      createCustomerUseCase: Get.find<CreateCustomerUseCase>(),
      updateCustomerUseCase: Get.find<UpdateCustomerUseCase>(),
      getCustomerUseCase: Get.find<GetCustomerUseCase>(),
    ));
  }
}
''',
    r'lib\features\customers\presentation\pages\customer_list_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/customer_controller.dart';

class CustomerListPage extends GetView<CustomerController> {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoading(message: 'Loading customers...');
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return AppError(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchCustomers,
                );
              }
              if (controller.customers.isEmpty) {
                return AppEmpty(
                  message: 'No customers found',
                  icon: Icons.people_outline,
                  actionLabel: 'Add Customer',
                  onAction: () => Get.toNamed('/customers/create'),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshCustomers,
                child: ListView.builder(
                  itemCount: controller.customers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.xs,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                          child: Text(
                            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.email ?? customer.phone ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Get.toNamed('/customers/edit', arguments: customer.id);
                            }
                            if (value == 'delete') {
                              controller.deleteCustomer(customer.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: () => Get.toNamed('/customers/${customer.id}', arguments: customer.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/customers/create');
          if (result == true) controller.fetchCustomers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''',
    r'lib\features\customers\presentation\pages\customer_detail_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customer.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Customer? customer;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    final id = Get.arguments as String?;
    if (id == null) {
      setState(() { errorMessage = 'Customer ID not provided'; isLoading = false; });
      return;
    }
    try {
      final result = await Get.find<GetCustomerUseCase>()(id);
      setState(() { customer = result; isLoading = false; });
    } on Failure catch (e) {
      setState(() { errorMessage = e.message; isLoading = false; });
    } catch (e) {
      setState(() { errorMessage = 'Failed to load customer'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer?.name ?? 'Customer Detail')),
      body: isLoading
          ? const AppLoading()
          : errorMessage.isNotEmpty
              ? AppError(message: errorMessage, onRetry: _loadCustomer)
              : customer == null
                  ? const AppError(message: 'Customer not found')
                  : ListView(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      children: [
                        _infoTile('Name', customer!.name),
                        if (customer!.email != null) _infoTile('Email', customer!.email!),
                        if (customer!.phone != null) _infoTile('Phone', customer!.phone!),
                        if (customer!.address != null) _infoTile('Address', customer!.address!),
                        if (customer!.company != null) _infoTile('Company', customer!.company!),
                      ],
                    ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
''',
    r'lib\features\customers\presentation\pages\customer_form_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/customer_form_controller.dart';

class CustomerFormPage extends GetView<CustomerFormController> {
  const CustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing ? 'Edit Customer' : 'New Customer')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoading();
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              AppTextField(
                controller: controller.nameController,
                label: 'Name',
                hint: 'Enter customer name',
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Enter email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: controller.phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: controller.addressController,
                label: 'Address',
                hint: 'Enter address',
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: controller.companyController,
                label: 'Company',
                hint: 'Enter company name',
              ),
              const SizedBox(height: AppDimensions.xl),
              Obx(() => AppButton(
                text: controller.isEditing ? 'Update Customer' : 'Create Customer',
                onPressed: controller.saveCustomer,
                isLoading: controller.isSaving.value,
              )),
            ],
          ),
        );
      }),
    );
  }
}
''',
    r'lib\features\orders\domain\entities\order.dart': '''class Order {
  final String id;
  final String? customerId;
  final String? customerName;
  final double totalAmount;
  final String status;
  final String? notes;
  final List<OrderItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    this.status = 'pending',
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Order && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class OrderItem {
  final String id;
  final String productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
''',
    r'lib\features\orders\domain\repositories\order_repository.dart': '''import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int? page, int? limit, String? status});
  Future<Order> getOrder(String id);
}
''',
    r'lib\features\orders\domain\usecases\get_orders.dart': '''import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;
  GetOrdersUseCase({required OrderRepository repository}) : _repository = repository;

  Future<List<Order>> call({int? page, int? limit, String? status}) {
    return _repository.getOrders(page: page, limit: limit, status: status);
  }
}
''',
    r'lib\features\orders\domain\usecases\get_order.dart': '''import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderUseCase {
  final OrderRepository _repository;
  GetOrderUseCase({required OrderRepository repository}) : _repository = repository;

  Future<Order> call(String id) => _repository.getOrder(id);
}
''',
    r'lib\features\orders\data\models\order_model.dart': '''import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    super.customerId,
    super.customerName,
    required super.totalAmount,
    super.status,
    super.notes,
    super.items,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
''',
    r'lib\features\orders\data\datasources\order_remote_datasource.dart': '''import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status});
  Future<OrderModel> getOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<OrderModel>> getOrders({int? page, int? limit, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _apiClient.get('/orders', queryParameters: queryParams);
    final data = response.data;
    List<dynamic> items;
    if (data is Map<String, dynamic>) {
      items = data['data'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final response = await _apiClient.get('/orders/$id');
    final data = response.data;
    final orderData = data is Map<String, dynamic> && data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return OrderModel.fromJson(orderData);
  }
}
''',
    r'lib\features\orders\data\repositories\order_repository_impl.dart': '''import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Order>> getOrders({int? page, int? limit, String? status}) async {
    try {
      return await _remoteDataSource.getOrders(page: page, limit: limit, status: status);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Order> getOrder(String id) async {
    try {
      return await _remoteDataSource.getOrder(id);
    } on NotFoundException {
      throw const NotFoundFailure(message: 'Order not found');
    } on AppException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
''',
    r'lib\features\orders\presentation\controllers\order_controller.dart': '''import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

class OrderController extends GetxController {
  final GetOrdersUseCase _getOrdersUseCase;

  OrderController({required GetOrdersUseCase getOrdersUseCase})
      : _getOrdersUseCase = getOrdersUseCase;

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _getOrdersUseCase(
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
      );
      orders.assignAll(result);
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
    fetchOrders();
  }

  Future<void> refreshOrders() => fetchOrders();
}
''',
    r'lib\features\orders\presentation\bindings\order_binding.dart': '''import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/get_order.dart';
import '../controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut(
      () => OrderRepositoryImpl(remoteDataSource: Get.find<OrderRemoteDataSource>()),
    );
    Get.lazyPut(() => GetOrdersUseCase(repository: Get.find<OrderRepositoryImpl>()));
    Get.lazyPut(() => GetOrderUseCase(repository: Get.find<OrderRepositoryImpl>()));
    Get.lazyPut(() => OrderController(getOrdersUseCase: Get.find<GetOrdersUseCase>()));
  }
}
''',
    r'lib\features\orders\presentation\pages\order_list_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/order_controller.dart';

class OrderListPage extends GetView<OrderController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Obx(() => Row(
              children: ['All', 'pending', 'processing', 'completed', 'cancelled'].map((status) {
                final isSelected = (status == 'All' && controller.selectedStatus.value.isEmpty) ||
                    controller.selectedStatus.value == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sm),
                  child: FilterChip(
                    label: Text(status[0].toUpperCase() + status.substring(1)),
                    selected: isSelected,
                    onSelected: (_) => controller.onStatusFilterChanged(
                      status == 'All' ? '' : status,
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const AppLoading(message: 'Loading orders...');
              if (controller.errorMessage.value.isNotEmpty) {
                return AppError(message: controller.errorMessage.value, onRetry: controller.fetchOrders);
              }
              if (controller.orders.isEmpty) {
                return const AppEmpty(message: 'No orders found', icon: Icons.shopping_cart_outlined);
              }
              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                child: ListView.builder(
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.xs,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.1),
                          child: Icon(
                            Icons.receipt_outlined,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        title: Text('Order #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.customerName != null) Text(order.customerName!),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Get.toNamed('/orders/${order.id}', arguments: order.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppColors.warning;
      case 'processing': return AppColors.info;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondaryLight;
    }
  }
}
''',
    r'lib\features\orders\presentation\pages\order_detail_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/get_order.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order? order;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final id = Get.arguments as String?;
    if (id == null) {
      setState(() { errorMessage = 'Order ID not provided'; isLoading = false; });
      return;
    }
    try {
      final result = await Get.find<GetOrderUseCase>()(id);
      setState(() { order = result; isLoading = false; });
    } on Failure catch (e) {
      setState(() { errorMessage = e.message; isLoading = false; });
    } catch (e) {
      setState(() { errorMessage = 'Failed to load order'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(order != null ? 'Order #${order!.id}' : 'Order Detail')),
      body: isLoading
          ? const AppLoading()
          : errorMessage.isNotEmpty
              ? AppError(message: errorMessage, onRetry: _loadOrder)
              : order == null
                  ? const AppError(message: 'Order not found')
                  : ListView(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order #${order!.id}',
                                    style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: AppDimensions.sm),
                                if (order!.customerName != null)
                                  Text('Customer: ${order!.customerName}'),
                                const SizedBox(height: AppDimensions.sm),
                                Chip(
                                  label: Text(order!.status.toUpperCase()),
                                  backgroundColor:
                                      _getStatusColor(order!.status).withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: AppDimensions.md),
                                Text(
                                  'Total: \$${order!.totalAmount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (order!.items != null && order!.items!.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.md),
                          Text('Items', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppDimensions.sm),
                          ...order!.items!.map((item) => Card(
                            child: ListTile(
                              title: Text(item.productName ?? 'Product ${item.productId}'),
                              subtitle: Text('Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}'),
                              trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                            ),
                          )),
                        ],
                        if (order!.notes != null) ...[
                          const SizedBox(height: AppDimensions.md),
                          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppDimensions.sm),
                          Text(order!.notes!),
                        ],
                      ],
                    ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppColors.warning;
      case 'processing': return AppColors.info;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondaryLight;
    }
  }
}
''',
    r'lib\features\profile\presentation\controllers\profile_controller.dart': '''import 'package:get/get.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';

class ProfileController extends GetxController {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileController({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      user.value = await _getCurrentUserUseCase();
    } on Failure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load profile';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
    );
    if (!confirmed) return;

    try {
      await _logoutUseCase();
      Get.offAllNamed('/login');
    } catch (e) {
      Helpers.showError('Failed to logout');
    }
  }
}
''',
    r'lib\features\profile\presentation\bindings\profile_binding.dart': '''import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(localStorage: Get.find<LocalStorage>()),
    );
    Get.lazyPut(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
    );
    Get.lazyPut(() => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => ProfileController(
      getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      logoutUseCase: Get.find<LogoutUseCase>(),
    ));
  }
}
''',
    r'lib\features\profile\presentation\pages\profile_page.dart': '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoading();
        if (controller.errorMessage.value.isNotEmpty) {
          return AppError(
            message: controller.errorMessage.value,
            onRetry: controller.loadProfile,
          );
        }

        final user = controller.user.value;
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            const SizedBox(height: AppDimensions.lg),
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Center(
              child: Text(
                user?.name ?? 'Unknown User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (user?.email != null)
              Center(
                child: Text(
                  user!.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ),
            const SizedBox(height: AppDimensions.xl),
            const Divider(),

            // Profile info tiles
            if (user?.phone != null)
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone'),
                subtitle: Text(user!.phone!),
              ),
            if (user?.role != null)
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Role'),
                subtitle: Text(user!.role!),
              ),

            const Divider(),
            const SizedBox(height: AppDimensions.md),

            // Logout button
            ElevatedButton.icon(
              onPressed: controller.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      }),
    );
  }
}
'''
}

for rel_path, content in files_to_create.items():
    abs_path = os.path.join(base_dir, rel_path)
    os.makedirs(os.path.dirname(abs_path), exist_ok=True)
    with open(abs_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Created: {abs_path}')

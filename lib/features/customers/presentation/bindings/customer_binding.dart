import 'package:get/get.dart';
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
    Get.lazyPut<CustomerRemoteDataSource>(() => CustomerRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => CustomerRepositoryImpl(remoteDataSource: Get.find<CustomerRemoteDataSource>()));
    Get.lazyPut(() => GetCustomersUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => GetCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => CreateCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => UpdateCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => DeleteCustomerUseCase(repository: Get.find<CustomerRepositoryImpl>()));
    Get.lazyPut(() => CustomerController(getCustomersUseCase: Get.find<GetCustomersUseCase>(), deleteCustomerUseCase: Get.find<DeleteCustomerUseCase>()));
    Get.lazyPut(() => CustomerFormController(createCustomerUseCase: Get.find<CreateCustomerUseCase>(), updateCustomerUseCase: Get.find<UpdateCustomerUseCase>(), getCustomerUseCase: Get.find<GetCustomerUseCase>()));
  }
}

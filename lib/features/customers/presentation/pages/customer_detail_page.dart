import 'package:flutter/material.dart';
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
  void initState() { super.initState(); _loadCustomer(); }

  Future<void> _loadCustomer() async {
    final id = Get.arguments as String?;
    if (id == null) { setState(() { errorMessage = 'Customer ID not provided'; isLoading = false; }); return; }
    try {
      final result = await Get.find<GetCustomerUseCase>()(id);
      setState(() { customer = result; isLoading = false; });
    } on Failure catch (e) { setState(() { errorMessage = e.message; isLoading = false; }); }
    catch (e) { setState(() { errorMessage = 'Failed to load customer'; isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer?.name ?? 'Customer Detail')),
      body: isLoading ? const AppLoading()
          : errorMessage.isNotEmpty ? AppError(message: errorMessage, onRetry: _loadCustomer)
          : customer == null ? const AppError(message: 'Customer not found')
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.md),
              children: [
                _tile('Name', customer!.name),
                if (customer!.email != null) _tile('Email', customer!.email!),
                if (customer!.phone != null) _tile('Phone', customer!.phone!),
                if (customer!.address != null) _tile('Address', customer!.address!),
                if (customer!.company != null) _tile('Company', customer!.company!),
              ],
            ),
    );
  }

  Widget _tile(String label, String value) => ListTile(
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
    subtitle: Text(value, style: const TextStyle(fontSize: 16)),
  );
}

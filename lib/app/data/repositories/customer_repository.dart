import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerRepository {
  final CustomerService customerService;

  CustomerRepository({required this.customerService});

  Future<List<CustomerModel>> getAllCustomers() async {
    final list = await customerService.getAllCustomers();
    return list.map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final res = await customerService.addCustomer(customer.toJson());
    return CustomerModel.fromJson(res);
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final res =
        await customerService.updateCustomer(customer.id, customer.toJson());
    return CustomerModel.fromJson(res);
  }

  Future<void> deleteCustomer(int id) async {
    await customerService.deleteCustomer(id);
  }

  Future<int> getCount() async {
    final customers = await getAllCustomers();
    return customers.length;
  }
}

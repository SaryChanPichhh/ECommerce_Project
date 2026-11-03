import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:final_project/features/auth/data/models/register_request_model.dart';
import 'package:final_project/features/auth/data/models/user_model.dart';
import 'package:final_project/features/auth/domain/entities/user.dart';
import 'package:final_project/features/auth/domain/usecases/register.dart';
import 'package:final_project/features/auth/presentation/controllers/signup_controller.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RegisterRequestModel Tests', () {
    test('serializes with admin role correctly', () {
      final model = RegisterRequestModel(
        email: 'admin@shop.com',
        password: 'Password123!',
        firstName: 'System',
        lastName: 'Admin',
        role: 'admin',
      );

      final json = model.toJson();
      expect(json['email'], 'admin@shop.com');
      expect(json['role'], 'admin');
    });

    test('serializes with customer role correctly', () {
      final model = RegisterRequestModel(
        email: 'user@shop.com',
        password: 'Password123!',
        role: 'customer',
      );

      final json = model.toJson();
      expect(json['email'], 'user@shop.com');
      expect(json['role'], 'customer');
    });
  });

  group('UserModel Role Detection Tests', () {
    test('preserves explicitly assigned admin role from server', () {
      final json = {
        'id': 'user-1',
        'email': 'someuser@example.com',
        'role': 'admin',
      };
      final user = UserModel.fromJson(json);
      expect(user.role, 'admin');
    });

    test('infers admin role when email contains admin if server roles are empty', () {
      final json = {
        'id': 'user-2',
        'email': 'admin@example.com',
        'roles': <String>[],
      };
      final user = UserModel.fromJson(json);
      expect(user.role, 'admin');
    });

    test('defaults to customer role for normal customer emails', () {
      final json = {
        'id': 'user-3',
        'email': 'customer@example.com',
      };
      final user = UserModel.fromJson(json);
      expect(user.role, 'customer');
    });
  });

  group('SignupController Admin Role Tests', () {
    late MockRegisterUseCase mockRegisterUseCase;
    late SignupController controller;

    setUp(() {
      Get.reset();
      mockRegisterUseCase = MockRegisterUseCase();
      controller = SignupController(registerUseCase: mockRegisterUseCase);
    });

    tearDown(() {
      controller.dispose();
      Get.reset();
    });

    test('initializes with customer role', () {
      expect(controller.selectedRole.value, 'customer');
    });

    test('can switch role to admin and back to customer', () {
      controller.setRole('admin');
      expect(controller.selectedRole.value, 'admin');

      controller.setRole('customer');
      expect(controller.selectedRole.value, 'customer');
    });

    test('rejects admin registration if secret key is incorrect', () async {
      controller.emailController.text = 'admin_new@test.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';
      controller.setRole('admin');
      controller.adminSecretController.text = 'WrongKey';

      await controller.signup();

      verifyNever(() => mockRegisterUseCase(
            email: any(named: 'email'),
            password: any(named: 'password'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            phoneNumber: any(named: 'phoneNumber'),
            role: any(named: 'role'),
          ));
    });

    test('proceeds with admin registration when secret key is correct', () async {
      controller.emailController.text = 'admin_new@test.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';
      controller.setRole('admin');
      controller.adminSecretController.text = 'AdminSecret123!';

      when(() => mockRegisterUseCase(
            email: 'admin_new@test.com',
            password: 'Password123!',
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            phoneNumber: any(named: 'phoneNumber'),
            role: 'admin',
          )).thenAnswer((_) async => const User(
            id: 'admin-id-1',
            name: 'Admin User',
            email: 'admin_new@test.com',
            role: 'admin',
          ));

      await controller.signup();

      verify(() => mockRegisterUseCase(
            email: 'admin_new@test.com',
            password: 'Password123!',
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            phoneNumber: any(named: 'phoneNumber'),
            role: 'admin',
          )).called(1);
    });
  });
}

# Flutter GetX + Clean Architecture Implementation Plan

## 1. Goal

Build a production-ready Flutter application using:

- Flutter
- Dart
- GetX
- Clean Architecture
- Feature-based structure
- REST API
- Dependency Injection
- Local Storage
- Authentication
- Error Handling
- Form Validation
- Unit Testing
- Widget Testing

The AI should implement the project incrementally rather than generating the entire application at once.

---

# 2. Architecture

Use this architecture:

```text
lib/
│
├── app/
│   ├── routes/
│   ├── bindings/
│   └── app.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── customers/
│   ├── orders/
│   └── profile/
│
└── main.dart
```

Each feature follows:

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── bindings/
    ├── controllers/
    ├── pages/
    └── widgets/
```

---

# 3. Implementation Phases

## Phase 1 — Project Initialization

### Tasks

- Create Flutter project.
- Configure Dart/Flutter version.
- Configure application name.
- Configure Android/iOS package identifiers.
- Add required dependencies.
- Create initial folder structure.
- Configure `main.dart`.
- Create `App` widget.

### Initial dependencies

Use only dependencies that are actually required.

Typical dependencies:

```text
get
dio
get_storage
json_annotation
freezed_annotation
```

Development dependencies:

```text
build_runner
json_serializable
freezed
flutter_lints
```

Do not add packages unnecessarily.

### Expected result

The application should run successfully with:

```text
main.dart
    ↓
App
    ↓
GetMaterialApp
```

---

# 4. Phase 2 — Core Infrastructure

Implement the shared infrastructure before implementing business features.

## 4.1 Constants

Create:

```text
core/constants/
├── api_constants.dart
├── app_constants.dart
└── storage_keys.dart
```

Example:

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
}
```

---

# 5. Network Layer

Use `Dio` for HTTP communication.

Create:

```text
core/network/
├── api_client.dart
├── network_info.dart
└── interceptors/
    ├── auth_interceptor.dart
    └── logging_interceptor.dart
```

The architecture should be:

```text
Controller
    ↓
UseCase
    ↓
Repository
    ↓
RemoteDataSource
    ↓
ApiClient
    ↓
Dio
    ↓
REST API
```

The controller must never directly call `Dio`.

---

# 6. API Client

Create a centralized API client.

Responsibilities:

- GET
- POST
- PUT
- PATCH
- DELETE
- Headers
- Authentication
- Timeout
- Error conversion
- Logging

Example API usage:

```dart
final response = await apiClient.get(
  '/products',
);
```

Do not create a new `Dio` instance inside every repository.

Use one configured API client.

---

# 7. Error Handling

Create:

```text
core/errors/
├── exceptions.dart
└── failures.dart
```

Define application-level errors such as:

```text
NetworkFailure
ServerFailure
UnauthorizedFailure
ValidationFailure
NotFoundFailure
UnknownFailure
```

The Data layer should convert technical exceptions into domain-level failures.

Example:

```text
DioException
      ↓
DataSource
      ↓
Failure
      ↓
UseCase
      ↓
Controller
      ↓
UI
```

The UI should not know what `DioException` is.

---

# 8. Local Storage

Create:

```text
core/storage/
└── local_storage.dart
```

Use storage for:

- Access token
- Refresh token
- User preferences
- Language
- Theme
- Selected branch
- Selected warehouse

Do not access `GetStorage` directly from every controller.

Instead:

```text
Controller
    ↓
Repository / Service
    ↓
LocalStorage
    ↓
GetStorage
```

---

# 9. Theme System

Create:

```text
core/theme/
├── app_theme.dart
├── app_colors.dart
├── app_text_styles.dart
└── app_dimensions.dart
```

Centralize:

- Colors
- Typography
- Spacing
- Border radius
- Button styles
- Input styles
- Light theme
- Dark theme

Avoid hardcoding colors throughout widgets.

Bad:

```dart
color: Colors.blue
```

Prefer:

```dart
color: AppColors.primary
```

---

# 10. Shared Widgets

Create reusable components:

```text
core/widgets/
├── app_button.dart
├── app_text_field.dart
├── app_loading.dart
├── app_error.dart
├── app_empty.dart
└── app_dialog.dart
```

Only put genuinely reusable widgets here.

Feature-specific widgets should remain inside their feature.

---

# 11. Phase 3 — Authentication Feature

Implement authentication first because other features will depend on it.

Structure:

```text
features/auth/
│
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   │
│   ├── models/
│   │   ├── login_request_model.dart
│   │   └── user_model.dart
│   │
│   └── repositories/
│       └── auth_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── user.dart
│   │
│   ├── repositories/
│   │   └── auth_repository.dart
│   │
│   └── usecases/
│       ├── login.dart
│       ├── logout.dart
│       └── get_current_user.dart
│
└── presentation/
    ├── bindings/
    │   └── auth_binding.dart
    │
    ├── controllers/
    │   └── login_controller.dart
    │
    ├── pages/
    │   └── login_page.dart
    │
    └── widgets/
        └── login_form.dart
```

---

# 12. Authentication Flow

Implement:

```text
Login Page
    ↓
Login Controller
    ↓
Login UseCase
    ↓
Auth Repository
    ↓
Auth Remote DataSource
    ↓
API
```

After successful login:

```text
API
 ↓
Access Token
 ↓
LocalStorage
 ↓
Auth State
 ↓
Home Page
```

Implement automatic authentication handling.

If the API returns:

```text
401 Unauthorized
```

the application should handle token expiration consistently.

---

# 13. Phase 4 — Routing

Create:

```text
app/routes/
├── app_routes.dart
└── app_pages.dart
```

Example:

```text
/login
/home
/products
/products/:id
/customers
/orders
/profile
```

Use GetX route bindings.

Example:

```dart
GetPage(
  name: AppRoutes.products,
  page: () => const ProductPage(),
  binding: ProductBinding(),
);
```

Avoid creating all controllers globally.

Controllers should normally be created when the feature is entered.

---

# 14. Phase 5 — Products Feature

Implement Products as the first complete CRUD feature.

Required operations:

```text
GET    /products
GET    /products/{id}
POST   /products
PUT    /products/{id}
DELETE /products/{id}
```

Structure:

```text
features/products/
├── data/
│   ├── datasources/
│   │   └── product_remote_datasource.dart
│   │
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── product_create_request.dart
│   │   └── product_update_request.dart
│   │
│   └── repositories/
│       └── product_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── product.dart
│   │
│   ├── repositories/
│   │   └── product_repository.dart
│   │
│   └── usecases/
│       ├── get_products.dart
│       ├── get_product.dart
│       ├── create_product.dart
│       ├── update_product.dart
│       └── delete_product.dart
│
└── presentation/
    ├── bindings/
    │   └── product_binding.dart
    │
    ├── controllers/
    │   ├── product_controller.dart
    │   └── product_form_controller.dart
    │
    ├── pages/
    │   ├── product_list_page.dart
    │   ├── product_detail_page.dart
    │   └── product_form_page.dart
    │
    └── widgets/
        ├── product_card.dart
        ├── product_search.dart
        └── product_form.dart
```

---

# 15. GetX State Management

Use reactive state where it provides value.

Example:

```dart
class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;
}
```

UI:

```dart
Obx(() {
  if (controller.isLoading.value) {
    return const AppLoading();
  }

  return ListView.builder(
    itemCount: controller.products.length,
    itemBuilder: (_, index) {
      return ProductCard(
        product: controller.products[index],
      );
    },
  );
});
```

Avoid making every variable reactive unnecessarily.

---

# 16. Form State

For complex forms, separate form state from list/page state.

Example:

```text
ProductController
    ↓
Product list state

ProductFormController
    ↓
Create/update product state
```

This prevents one large controller from becoming responsible for everything.

---

# 17. Phase 6 — Additional Features

After Products, implement features using the same pattern:

```text
customers/
orders/
payments/
profile/
settings/
notifications/
```

Each feature should be independent.

Do not create a giant:

```text
AppController
```

that manages the entire application.

---

# 18. Dependency Injection Strategy

Use GetX Bindings.

Example:

```text
ProductBinding
    │
    ├── ApiClient
    ├── ProductRemoteDataSource
    ├── ProductRepository
    ├── GetProductsUseCase
    ├── CreateProductUseCase
    └── ProductController
```

Use:

```dart
Get.lazyPut(...)
```

for dependencies that should be created lazily.

Use:

```dart
Get.put(...)
```

only when an object genuinely needs immediate/global lifetime.

---

# 19. Testing Strategy

Every important layer should be testable.

## Unit Tests

Test:

```text
UseCases
Repositories
Controllers
Validators
Mappers
```

Example:

```text
test/
├── features/
│   ├── auth/
│   └── products/
│
└── core/
    ├── network/
    └── utils/
```

## Widget Tests

Test:

```text
LoginPage
ProductPage
ProductForm
ProductCard
```

## Integration Tests

Test important user flows:

```text
Login
 ↓
Home
 ↓
Products
 ↓
Create Product
 ↓
Product Detail
```

---

# 20. AI Implementation Rules

When using AI to implement this project, **do not ask the AI to generate the entire application in one prompt**.

Implement in small stages.

Use this sequence:

```text
1. Project setup
2. Dependencies
3. Folder structure
4. Core configuration
5. Network layer
6. Error handling
7. Local storage
8. Theme
9. Routing
10. Authentication
11. Products
12. Testing
13. Additional features
14. Refactoring
```

After each stage:

```text
Run application
    ↓
Check analyzer
    ↓
Run tests
    ↓
Fix errors
    ↓
Continue
```

---

# 21. AI Coding Rules

Give the AI these rules:

### Rule 1 — Respect Architecture

Do not put API calls inside:

```text
Page
Widget
Controller
```

### Rule 2 — Respect Dependency Direction

Use:

```text
Presentation
    ↓
Domain
    ↓
Data
```

The Domain layer must not depend on Flutter, GetX, Dio, or storage implementations.

### Rule 3 — GetX Only in Presentation

GetX should primarily be used for:

```text
Controller
Binding
Navigation
Reactive UI state
```

Do not put GetX dependencies inside Domain entities or UseCases.

### Rule 4 — Reuse Infrastructure

Do not create multiple:

```text
Dio
ApiClient
LocalStorage
```

instances unnecessarily.

### Rule 5 — No Giant Controllers

If a controller becomes responsible for:

```text
List
Create
Update
Delete
Search
Filter
Form
Authentication
Navigation
```

split the responsibilities.

### Rule 6 — No Giant Widgets

If a page becomes too large, extract:

```text
widgets/
```

into smaller components.

### Rule 7 — Strong Typing

Avoid:

```dart
Map<String, dynamic>
```

throughout the application.

Prefer:

```dart
Product
User
Order
ProductModel
LoginRequest
```

### Rule 8 — Handle Loading/Error/Empty States

Every API-driven screen should consider:

```text
Loading
Success
Empty
Error
```

---

# 22. Recommended AI Prompt Sequence

## Prompt 1 — Architecture

Ask AI:

> Create the Flutter project structure using GetX and Clean Architecture. Use a feature-based architecture with app, core, and features folders. Do not implement business features yet. Explain the responsibility of every folder.

---

## Prompt 2 — Core

> Implement the core infrastructure: API client using Dio, local storage, error handling, constants, theme, reusable widgets, and logging. Keep Domain independent from Flutter, GetX, Dio, and storage implementations.

---

## Prompt 3 — Routing

> Implement GetX routing and bindings. Create application routes for splash, login, home, products, customers, orders, and profile. Use lazy dependency injection and avoid creating all feature controllers globally.

---

## Prompt 4 — Authentication

> Implement the authentication feature using the existing architecture. Include data, domain, and presentation layers. Implement login, logout, current-user retrieval, token storage, authentication interceptor, loading state, error state, and form validation.

---

## Prompt 5 — Products

> Implement the Products feature following exactly the same architecture as Authentication. Include CRUD operations, models, entities, repository contract, repository implementation, remote datasource, use cases, GetX controllers, bindings, pages, widgets, loading/error/empty states, and validation.

---

## Prompt 6 — Testing

> Add unit tests for the Products use cases, repository, and controller. Add widget tests for ProductListPage and ProductFormPage. Mock external dependencies instead of calling the real API.

---

# 23. Final Architecture

The final project should look approximately like:

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── bindings/
│       └── initial_binding.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   │
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── customers/
│   ├── orders/
│   ├── payments/
│   └── profile/
│
└── main.dart

test/
│
├── core/
└── features/
    ├── auth/
    ├── products/
    ├── customers/
    └── orders/
```

## Main Principle

The goal is not simply to use **GetX everywhere**.

Use each technology for the responsibility it is good at:

```text
Flutter
   ↓
UI

GetX
   ↓
State + DI + Navigation

Clean Architecture
   ↓
Separation of concerns

Dio
   ↓
HTTP

Local Storage
   ↓
Persistence

Domain
   ↓
Business rules

Data
   ↓
External data sources
```

The result should be a Flutter application where adding a new feature such as `Orders` does not require modifying unrelated `Products`, `Auth`, or `Customers` code.
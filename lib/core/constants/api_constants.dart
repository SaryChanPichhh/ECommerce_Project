/// Centralized API configuration constants for SETEC eCommerce.
/// Strict trailing slashes are enforced per the backend integration guide.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://setec-mobile-ecommerce-service.onrender.com/api/v1';

  // Alternative environment hosts documented in Section 1.1:
  // Android Emulator: 'http://10.0.2.2:8000/api/v1'
  // Localhost (Web / iOS): 'http://localhost:8000/api/v1'

  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;

  // ──────────────────────────────────────────────
  // 1. Auth & Session Endpoints (Section 7.1 & 8.1)
  // ──────────────────────────────────────────────
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String legacyLogin = '/legacy-auth/login';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/refresh/';
  static const String forgotPassword = '/auth/forgot-password/';
  static const String resetPassword = '/auth/reset-password/';
  static const String verifyEmail = '/auth/verify-email/';
  static const String verifyPhone = '/auth/verify-phone/';
  static const String authMe = '/auth/me/';
  static const String currentUser = '/auth/me/';
  static const String userMe = '/users/me/';

  // ──────────────────────────────────────────────
  // 2. User Profile & Account Settings (Section 8.2)
  // ──────────────────────────────────────────────
  static const String userProfile = '/users/me/profile/';
  static const String userSecuritySettings = '/users/me/security-settings/';
  static const String userSessions = '/users/me/sessions/';
  static String userSessionRevoke(String sessionId) =>
      '/users/me/sessions/$sessionId/';
  static const String userReviews = '/users/me/reviews/';
  static const String userLegalAcceptances = '/users/me/legal-acceptances/';

  // ──────────────────────────────────────────────
  // 3. Home Feed (Section 7.2)
  // ──────────────────────────────────────────────
  static const String home = '/home/';
  static const String publicHome = '/public/home/';

  // ──────────────────────────────────────────────
  // 4. Storefront Categories (Section 7.3)
  // ──────────────────────────────────────────────
  static const String publicCategories = '/public/categories/';
  static const String publicCategoriesTree = '/public/categories/tree/';
  static String publicCategoryDetail(String categoryId) =>
      '/public/categories/$categoryId/';
  static const String publicCategorySearch = '/public/categories/search/';

  // ──────────────────────────────────────────────
  // 5. Stores Catalog (Section 7.4)
  // ──────────────────────────────────────────────
  static const String publicStores = '/public/stores/';
  static String publicStoreDetail(String storeId) =>
      '/public/stores/$storeId/';
  static String publicStoreProducts(String storeId) =>
      '/public/stores/$storeId/products/';
  static const String publicStoreSearch = '/public/stores/search/';
  static const String publicStoreSearchProducts =
      '/public/stores/search/products/';

  // ──────────────────────────────────────────────
  // 6. Tags Catalog (Section 7.5)
  // ──────────────────────────────────────────────
  static const String publicTags = '/public/tags/';
  static const String tags = '/tags/';

  // ──────────────────────────────────────────────
  // 7. Products Catalog & Search (Section 7.6)
  // ──────────────────────────────────────────────
  static const String publicProducts = '/public/products/';
  static const String products = '/products/';
  static const String adminProducts = '/admin/products/';
  static String _cleanId(String id) => id.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  static String publicProductDetail(String productId) =>
      '/public/products/${_cleanId(productId)}/';
  static String productDetail(String productId) =>
      '/products/${_cleanId(productId)}/';
  static String adminProductDetail(String productId) =>
      '/admin/products/${_cleanId(productId)}/';
  static String publicProductBySlug(String storeSlug, String productSlug) =>
      '/public/products/slug/$storeSlug/$productSlug/';
  static String publicProductImages(String productId) =>
      '/public/products/${_cleanId(productId)}/images/';
  static String publicProductVariants(String productId) =>
      '/public/products/${_cleanId(productId)}/variants/';
  static const String publicVariantsStandalone = '/public/product/variants/';
  static String publicVariantDetail(String variantId) =>
      '/public/product/variants/$variantId/';
  static const String publicVariantOptions = '/public/product/variant-options/';
  static String publicVariantOptionDetail(String optionId) =>
      '/public/product/variant-options/$optionId/';

  // ──────────────────────────────────────────────
  // 8. Product Reviews (Section 7.7 & 8.9)
  // ──────────────────────────────────────────────
  static String publicProductReviews(String productId) =>
      '/public/products/$productId/reviews/';
  static const String reviews = '/reviews/';
  static String reviewDetail(String reviewId) => '/reviews/$reviewId/';
  static String customerProductReviews(String productId) =>
      '/products/$productId/reviews/';

  // ──────────────────────────────────────────────
  // 9. Legal Documents (Section 7.8 & 8.13)
  // ──────────────────────────────────────────────
  static const String legalDocuments = '/legal-documents/';
  static String legalDocumentLatest(String type) =>
      '/legal-documents/$type/latest/';
  static String acceptLegalDocument(String documentId) =>
      '/legal-documents/$documentId/accept/';

  // ──────────────────────────────────────────────
  // 10. Shipping Addresses (Section 8.3)
  // ──────────────────────────────────────────────
  static const String addresses = '/addresses/';
  static const String customerAddresses = '/customer/addresses/';
  static String addressDetail(String addressId) => '/addresses/$addressId/';
  static String customerAddressDetail(String addressId) =>
      '/customer/addresses/$addressId/';
  static String addressDefault(String addressId) =>
      '/customer/addresses/$addressId/default/';
  static String customerAddressDefault(String addressId) =>
      '/customer/addresses/$addressId/default/';

  // ──────────────────────────────────────────────
  // 11. Shopping Cart & Checkout Preview (Section 8.4)
  // ──────────────────────────────────────────────
  static const String cart = '/cart/';
  static const String customerCart = '/customer/cart/';
  static const String cartItems = '/cart/items/';
  static const String customerCartItems = '/customer/cart/items/';
  static String cartItemDetail(String cartItemId) =>
      '/cart/items/$cartItemId/';
  static String customerCartItemDetail(String cartItemId) =>
      '/customer/cart/items/$cartItemId/';
  static const String cartSelectAll = '/cart/select-all/';
  static const String customerCartSelectAll = '/customer/cart/select-all/';
  static const String cartCheckoutPreview = '/cart/checkout-preview/';
  static const String customerCartCheckoutPreview =
      '/customer/cart/checkout-preview/';

  // ──────────────────────────────────────────────
  // 12. Orders, Payments & Checkout (Section 8.5 & order_process.md)
  // ──────────────────────────────────────────────
  static const String orders = '/orders/';
  static const String customerOrders = '/customer/orders/';
  static const String customerOrdersPayment = '/customer/orders/payment/';
  static String orderDetail(String orderId) => '/orders/${_cleanId(orderId)}/';
  static String customerOrderDetail(String orderId) =>
      '/customer/orders/${_cleanId(orderId)}/';
  static String customerOrderPayment(String orderId) =>
      '/customer/orders/${_cleanId(orderId)}/payment/';
  static String orderCancel(String orderId) =>
      '/orders/${_cleanId(orderId)}/cancel/';
  static String customerOrderCancel(String orderId) =>
      '/customer/orders/${_cleanId(orderId)}/cancel/';
  static String orderStatusHistory(String orderId) =>
      '/orders/${_cleanId(orderId)}/status-history/';
  static String customerOrderStatusHistory(String orderId) =>
      '/customer/orders/${_cleanId(orderId)}/status-history/';
  static String orderShipments(String orderId) =>
      '/orders/${_cleanId(orderId)}/shipments/';
  static String customerOrderShipments(String orderId) =>
      '/customer/orders/${_cleanId(orderId)}/shipments/';

  // Admin Order Fulfillment Routes (order_process.md Steps 9-11 & Admin Cancel/Fail)
  static const String adminOrders = '/admin/orders/';
  static String adminOrderDetail(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/';
  static String adminOrderStatus(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/status/';
  static String adminOrderProcessing(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/processing';
  static String adminOrderShipments(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/shipments';
  static String adminOrderCancel(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/cancel';
  static String adminOrderFailed(String orderId) =>
      '/admin/orders/${_cleanId(orderId)}/failed';

  // ──────────────────────────────────────────────
  // 13. Shipments & Tracking (Section 8.6 & order_process.md Steps 12-17)
  // ──────────────────────────────────────────────
  static String shipmentDetail(String shipmentId) =>
      '/shipments/${_cleanId(shipmentId)}/';
  static String customerShipmentDetail(String shipmentId) =>
      '/customer/shipments/${_cleanId(shipmentId)}/';
  static String shipmentEvents(String shipmentId) =>
      '/shipments/${_cleanId(shipmentId)}/events/';
  static String customerShipmentEvents(String shipmentId) =>
      '/customer/shipments/${_cleanId(shipmentId)}/events/';
  static String customerShipmentConfirmDelivery(String shipmentId) =>
      '/customer/shipments/${_cleanId(shipmentId)}/confirm-delivery';
  static String customerShipmentConfirmDeliverySlash(String shipmentId) =>
      '/customer/shipments/${_cleanId(shipmentId)}/confirm-delivery/';

  // Admin Shipment Fulfillment Routes (order_process.md Steps 12-15)
  static const String adminShipments = '/admin/shipments/';
  static String adminShipmentDetail(String shipmentId) =>
      '/admin/shipments/${_cleanId(shipmentId)}/';
  static String adminShipmentPacked(String shipmentId) =>
      '/admin/shipments/${_cleanId(shipmentId)}/packed';
  static String adminShipmentHandoff(String shipmentId) =>
      '/admin/shipments/${_cleanId(shipmentId)}/handoff';
  static String adminShipmentEvents(String shipmentId) =>
      '/admin/shipments/${_cleanId(shipmentId)}/events';
  static String adminShipmentOutForDelivery(String shipmentId) =>
      '/admin/shipments/${_cleanId(shipmentId)}/out-for-delivery';

  // ──────────────────────────────────────────────
  // 14. Favorites & Wishlist (Section 8.7)
  // ──────────────────────────────────────────────
  static const String favorites = '/favorites/';
  static const String customerFavorites = '/customer/favorites/';
  static String favoriteProduct(String productId) => '/favorites/$productId/';
  static String customerFavoriteProduct(String productId) =>
      '/customer/favorites/$productId/';
  static String productFavoriteStatus(String productId) =>
      '/products/$productId/favorite/';

  // ──────────────────────────────────────────────
  // 15. Search History (Section 8.8)
  // ──────────────────────────────────────────────
  static const String searchHistory = '/search-history/';
  static const String customerSearchHistory = '/customer/search-history/';
  static String searchHistoryItem(String searchId) =>
      '/search-history/$searchId/';
  static String customerSearchHistoryItem(String searchId) =>
      '/customer/search-history/$searchId/';

  // ──────────────────────────────────────────────
  // 16. Chat / Conversations (Section 8.10)
  // ──────────────────────────────────────────────
  static const String conversations = '/conversations/';
  static const String customerConversations = '/customer/conversations/';
  static String conversationDetail(String conversationId) =>
      '/conversations/$conversationId/';
  static String customerConversationDetail(String conversationId) =>
      '/customer/conversations/$conversationId/';
  static String conversationMessages(String conversationId) =>
      '/conversations/$conversationId/messages/';
  static String customerConversationMessages(String conversationId) =>
      '/customer/conversations/$conversationId/messages/';
  static String messageRead(String messageId) =>
      '/messages/$messageId/read/';
  static String customerMessageRead(String messageId) =>
      '/customer/messages/$messageId/read/';

  // ──────────────────────────────────────────────
  // 17. In-App Notifications (Section 8.11)
  // ──────────────────────────────────────────────
  static const String notifications = '/notifications/';
  static const String customerNotifications = '/customer/notifications/';
  static const String notificationsUnreadCount =
      '/notifications/unread-count/';
  static const String customerNotificationsUnreadCount =
      '/customer/notifications/unread-count/';
  static const String notificationsReadAll = '/notifications/read-all/';
  static const String customerNotificationsReadAll =
      '/customer/notifications/read-all/';
  static String notificationDetail(String notificationId) =>
      '/notifications/$notificationId/';
  static String customerNotificationDetail(String notificationId) =>
      '/customer/notifications/$notificationId/';
  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read/';
  static String customerNotificationRead(String notificationId) =>
      '/customer/notifications/$notificationId/read/';

  // ──────────────────────────────────────────────
  // 18. Customer Support Tickets (Section 8.12)
  // ──────────────────────────────────────────────
  static const String supportTickets = '/support/tickets/';
  static const String customerSupportTickets = '/customer/support/tickets/';
  static String supportTicketDetail(String ticketId) =>
      '/support/tickets/$ticketId/';
  static String customerSupportTicketDetail(String ticketId) =>
      '/customer/support/tickets/$ticketId/';
  static String supportTicketMessages(String ticketId) =>
      '/support/tickets/$ticketId/messages/';
  static String customerSupportTicketMessages(String ticketId) =>
      '/customer/support/tickets/$ticketId/messages/';

  // ──────────────────────────────────────────────
  // 19. Cloudinary Uploads (Section 6 & 8.14)
  // ──────────────────────────────────────────────
  static const String cloudinarySignature = '/uploads/cloudinary-signature/';
  static const String customerCloudinarySignature =
      '/customer/uploads/cloudinary-signature/';
  static const String confirmUpload = '/uploads/confirm/';
  static const String customerConfirmUpload = '/customer/uploads/confirm/';
}

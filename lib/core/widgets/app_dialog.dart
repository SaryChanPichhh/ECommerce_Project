import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_dimensions.dart';

/// Reusable dialog utility.
class AppDialog {
  AppDialog._();

  /// Show a simple alert dialog.
  static Future<void> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog and return the result.
  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: isDanger
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show a loading dialog (non-dismissible).
  static void showLoading({String message = 'Loading...'}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppDimensions.md),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide the loading dialog.
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

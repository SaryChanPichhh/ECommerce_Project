import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await GetStorage.init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) {
        return App();
      },
    ),
  );
}

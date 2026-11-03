import 'package:get/get.dart';
import 'langs/en_us.dart';
import 'langs/km_kh.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'en': enUS,
        'km_KH': kmKH,
        'km': kmKH,
      };
}

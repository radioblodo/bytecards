// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '字卡';

  @override
  String get settings => '设置';

  @override
  String get home => '首页';

  @override
  String get statistics => '统计';

  @override
  String get reminderFrequency => '提醒频率';

  @override
  String get language => '语言';

  @override
  String get appTheme => '应用主题';

  @override
  String get daily => '每天';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get english => '英文';

  @override
  String get mandarin => '中文';

  @override
  String get selectTheme => '选择主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get systemDefault => '系统默认';

  @override
  String get noDecksMessage => '你还没有卡组。点击 + 创建一个。';

  @override
  String get generatedCards => 'AI生成的卡片：';

  @override
  String unsupportedFormat(Object ext) {
    return 'Unsupported format: .$ext';
  }

  @override
  String get fileReadError => 'Error reading file';

  @override
  String get parseError => 'Failed to parse AI response';

  @override
  String apiError(Object code) {
    return 'API error: $code';
  }

  @override
  String get cardsAdded => 'Flashcards added to deck!';

  @override
  String get confirmAddAll => 'Confirm & Add All to Deck';
}

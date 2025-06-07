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
  String get homeTitle => '微卡';

  @override
  String get statisticsTitle => '学习统计';

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
  String get noDecksMessage => "您还没有创建任何字卡。点击 + 创建一个。";

  @override
  String get statisticsDescription => '查看您的学习进度和统计数据，以便更好地了解您的学习习惯。';

  @override
  String get generateFromAI => '从 AI 生成';

  @override
  String get practiceNow => '立即练习';

  @override
  String get manuallyAddCards => '手动添加卡片';

  @override
  String get cardsAdded => '已添加卡片';

  @override
  String get confirmAddAll => '确认添加所有卡片';

  @override
  String get unsupportedFormat => '不支持的文件格式';

  @override
  String get parseError => '解析错误，请检查文件格式是否正确。';

  @override
  String apiError(String error) {
    return 'API 错误: $error';
  }

  @override
  String get fileReadError => '文件读取错误';
}

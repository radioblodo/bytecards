// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get difficultyTitle => "难度评级";

  @override
  String get easyLabel => "简单";

  @override
  String get mediumLabel => "中等";

  @override
  String get hardLabel => "困难";

  @override
  String reviewsOnDate(int count, String date) => '在 $date 已复习 $count 张字卡。';

  @override
  String noReviewsOnDate(String date) => '在 $date 没有复习记录。';

  @override
  String get reviewCalendar => '复习日历';

  @override
  String upcomingReviewsAmt(int count) => '有 $count 张卡片即将到期';

  @override
  String get noUpcomingReviews => '尚未安排任何即将复习。';

  @override
  String get upcomingReviews => '即将复习';

  @override
  String cardsReviewedToday(int count) => '您今天已复习 $count 张字卡！';

  @override
  String get noCardsReviewedToday => '您今天尚未复习任何字卡。';

  @override
  String get today => '今日份学习记录';

  @override
  String get apiKeySaved => '成功保存密钥';

  @override
  String get failedToOpenLink => '无法打开链接';

  @override
  String get save => '保存';

  @override
  String get guideToObtainAPIKey => '🔗 如何获取您的 API 密钥？';

  @override
  String get enterAPIKey => '点击此处输入您的密钥';

  @override
  String get aiModelAPIKey => 'AI 模型 API 密钥';

  @override
  String get saveFlashcard => '保存字卡';

  @override
  String get answer => '答案';

  @override
  String get question => '问题';

  @override
  String get addFlashcard => '添加字卡';

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

  @override
  String get cancel => '取消';

  @override
  String get flashcards => '卡片';

  @override
  String get createDeck => '创建字卡组';

  @override
  String get createDeckButton => '新建字卡组';

  @override
  String get deckName => '字卡组名称';

  @override
  String get noFlashcardsAvailable => '没有可用的卡片';

  @override
  String get practiceMode => '练习模式';

  @override
  // TODO: implement cardCountsTitle
  String get cardCountsTitle => "字卡数量";

  @override
  String matureCards(int count) {
    return "已掌握字卡：$count";
  }

  @override
  String newCards(int count) {
    return "新字卡：$count";
  }

  @override
  String youngCards(int count) {
    return "学习中字卡：$count";
  }

  @override
  String get reviewIntervals => "复习分布";
}

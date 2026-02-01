import '../models/channel.dart';

/// واجهة لمصدر بيانات القنوات
/// يمكن تنفيذها من مصادر مختلفة (API، قاعدة بيانات محلية، إلخ)
abstract class ChannelDataSource {
  /// الحصول على جميع القنوات التلفزيونية
  Future<List<Channel>> getChannels();

  /// الحصول على جميع المحطات الإذاعية
  Future<List<Channel>> getRadioChannels();

  /// الحصول على قناة حسب ID
  Future<Channel?> getChannelById(String id);
}

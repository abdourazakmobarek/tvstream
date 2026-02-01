import '../datasources/channel_data_source.dart';
import '../models/channel.dart';

/// مستودع القنوات - يعمل كطبقة وسيطة بين Logic و Data Source
class ChannelRepository {
  final ChannelDataSource _dataSource;

  ChannelRepository(this._dataSource);

  /// الحصول على جميع القنوات التلفزيونية
  Future<List<Channel>> getChannels() async {
    try {
      return await _dataSource.getChannels();
    } catch (e) {
      // يمكن إضافة معالجة أخطاء أو cache هنا
      rethrow;
    }
  }

  /// الحصول على جميع المحطات الإذاعية
  Future<List<Channel>> getRadioChannels() async {
    try {
      return await _dataSource.getRadioChannels();
    } catch (e) {
      // يمكن إضافة معالجة أخطاء أو cache هنا
      rethrow;
    }
  }

  /// الحصول على قناة حسب ID
  Future<Channel?> getChannelById(String id) async {
    try {
      return await _dataSource.getChannelById(id);
    } catch (e) {
      return null;
    }
  }
}

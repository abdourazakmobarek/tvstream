import 'dart:convert';
import 'package:http/http.dart' as http;
import 'channel_data_source.dart';
import 'asset_channel_data_source.dart';
import '../models/channel.dart';

/// مصدر بيانات عن بُعد مع fallback محلي
/// يحاول جلب البيانات من الشبكة أولاً، وعند الفشل يستخدم ملف channels.json المحلي
class RemoteChannelDataSource implements ChannelDataSource {
  final http.Client client;
  final AssetChannelDataSource _assetFallback = AssetChannelDataSource();

  final String _dataUrl =
      'https://raw.githubusercontent.com/abdourazakmobarek/tvstream/main/channels.json';

  RemoteChannelDataSource({required this.client});

  List<Channel>? _cachedChannels;

  Future<List<Channel>> _fetchAllChannels() async {
    // إذا كانت البيانات مخزنة مؤقتًا، أعدها مباشرة
    if (_cachedChannels != null) return _cachedChannels!;

    try {
      final response = await client
          .get(Uri.parse(_dataUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(decodedBody);
        _cachedChannels =
            jsonList.map((json) => Channel.fromJson(json)).toList();
        return _cachedChannels!;
      } else {
        // فشل الاستجابة من الخادم، استخدم البيانات المحلية
        return _loadFromAssetFallback();
      }
    } catch (e) {
      // أي خطأ (شبكة، timeout، parsing...) -> استخدم البيانات المحلية
      return _loadFromAssetFallback();
    }
  }

  Future<List<Channel>> _loadFromAssetFallback() async {
    final channels = await _assetFallback.getChannels();
    final radio = await _assetFallback.getRadioChannels();
    _cachedChannels = [...channels, ...radio];
    return _cachedChannels!;
  }

  @override
  Future<List<Channel>> getChannels() async {
    final all = await _fetchAllChannels();
    return all
        .where((c) => c.category == 'Public' || c.category == 'Private')
        .toList();
  }

  @override
  Future<List<Channel>> getRadioChannels() async {
    final all = await _fetchAllChannels();
    return all.where((c) => c.category == 'Radio').toList();
  }

  @override
  Future<Channel?> getChannelById(String id) async {
    final all = await _fetchAllChannels();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

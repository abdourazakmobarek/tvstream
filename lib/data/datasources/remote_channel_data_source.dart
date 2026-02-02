import 'dart:convert';
import 'package:http/http.dart' as http;
import 'channel_data_source.dart';
import '../models/channel.dart';

/// مصدر بيانات عن بُعد لجلب القنوات من ملف JSON
class RemoteChannelDataSource implements ChannelDataSource {
  final http.Client client;
  
  // رابط ملف القنوات (سأقوم بإنشاء ملف مثال لك لرفعه)
  final String _dataUrl = 'https://raw.githubusercontent.com/abdourazakmobarek/tvstream/main/channels.json';

  RemoteChannelDataSource({required this.client});

  Future<List<Channel>> _fetchAllChannels() async {
    try {
      final response = await client.get(Uri.parse(_dataUrl));

      if (response.statusCode == 200) {
        // فك تشفير البيانات باستخدام UTF-8 لدعم اللغة العربية
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(decodedBody);
        return jsonList.map((json) => Channel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load channels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  @override
  Future<List<Channel>> getChannels() async {
    final all = await _fetchAllChannels();
    // تصفية القنوات التلفزيونية (Public + Private)
    return all.where((c) => c.category == 'Public' || c.category == 'Private').toList();
  }

  @override
  Future<List<Channel>> getRadioChannels() async {
    final all = await _fetchAllChannels();
    // تصفية المحطات الإذاعية
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

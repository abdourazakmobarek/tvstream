import 'dart:convert';
import 'package:flutter/services.dart';
import 'channel_data_source.dart';
import '../models/channel.dart';

/// مصدر بيانات يقرأ من ملف channels.json المدمج مع التطبيق
class AssetChannelDataSource implements ChannelDataSource {
  List<Channel>? _cachedChannels;

  Future<List<Channel>> _loadFromAsset() async {
    if (_cachedChannels != null) return _cachedChannels!;

    final String jsonString = await rootBundle.loadString('channels.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _cachedChannels = jsonList.map((json) => Channel.fromJson(json)).toList();
    return _cachedChannels!;
  }

  @override
  Future<List<Channel>> getChannels() async {
    final all = await _loadFromAsset();
    return all.where((c) => c.category == 'Public' || c.category == 'Private').toList();
  }

  @override
  Future<List<Channel>> getRadioChannels() async {
    final all = await _loadFromAsset();
    return all.where((c) => c.category == 'Radio').toList();
  }

  @override
  Future<Channel?> getChannelById(String id) async {
    final all = await _loadFromAsset();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

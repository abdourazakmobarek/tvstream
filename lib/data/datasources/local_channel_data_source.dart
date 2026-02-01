import 'channel_data_source.dart';
import '../models/channel.dart';

/// مصدر بيانات محلي للقنوات (بيانات ثابتة حالياً)
/// يمكن استبداله بمصدر API في المستقبل
class LocalChannelDataSource implements ChannelDataSource {
  @override
  Future<List<Channel>> getChannels() async {
    // محاكاة تأخير بسيط لمحاكاة استدعاء API
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      const Channel(
        id: '1',
        name: 'El Mouritaniya',
        nameAr: 'الموريتانية',
        logoUrl: 'assets/images/الموريتانية.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Public',
      ),
      const Channel(
        id: '2',
        name: 'El Mouritaniya 2',
        nameAr: 'الموريتانية 2',
        logoUrl: 'assets/images/الموريتانية.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Public',
      ),
      const Channel(
        id: '3',
        name: 'Al Wataniya',
        nameAr: 'الوطنية',
        logoUrl: 'assets/images/الوطنية.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '4',
        name: 'Chinguivit TV',
        nameAr: 'شنقيط',
        logoUrl: 'assets/images/شنقيط.png',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '5',
        name: 'El Mdina',
        nameAr: 'المدينة',
        logoUrl: 'assets/images/المدينة.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '6',
        name: 'Dava',
        nameAr: 'دافا',
        logoUrl: 'assets/images/دافا.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '7',
        name: 'Al Sahel',
        nameAr: 'الساحل',
        logoUrl: 'assets/images/الساحل.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '8',
        name: 'Al Mourabitoun',
        nameAr: 'المرابطون',
        logoUrl: 'assets/images/المرابطون.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '9',
        name: 'Sahara 24',
        nameAr: 'صحراء 24',
        logoUrl: 'assets/images/صحراء24.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '10',
        name: 'Qimam',
        nameAr: 'قمم',
        logoUrl: 'assets/images/قمم.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Private',
      ),
      const Channel(
        id: '11',
        name: 'Al Mahadra',
        nameAr: 'المحظرة',
        logoUrl: 'assets/images/المحظرة.jpg',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Public',
      ),
    ];
  }

  @override
  Future<List<Channel>> getRadioChannels() async {
    // محاكاة تأخير بسيط لمحاكاة استدعاء API
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      const Channel(
        id: 'r1',
        name: 'Radio Mauritanie',
        nameAr: 'إذاعة موريتانيا',
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSflsFcJqmvTAzF_rvfNzeO5fQn7qLjoLqG7Q&s',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Radio',
      ),
      const Channel(
        id: 'r2',
        name: 'Radio Coran',
        nameAr: 'إذاعة القرآن الكريم',
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_xXkG9k9_xXkG9k9_xXkG9k9_xXkG9k9_xQ&s',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Radio',
      ),
      const Channel(
        id: 'r3',
        name: 'Radio Jeunesse',
        nameAr: 'إذاعة الشباب',
        logoUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_xXkG9k9_xXkG9k9_xXkG9k9_xXkG9k9_xQ&s',
        streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: 'Radio',
      ),
    ];
  }

  @override
  Future<Channel?> getChannelById(String id) async {
    final allChannels = [
      ...await getChannels(),
      ...await getRadioChannels(),
    ];
    
    try {
      return allChannels.firstWhere((channel) => channel.id == id);
    } catch (e) {
      return null;
    }
  }
}

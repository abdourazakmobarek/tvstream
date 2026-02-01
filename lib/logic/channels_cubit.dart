import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/channel.dart';
import '../data/repositories/channel_repository.dart';

/// حالات تحميل القنوات
abstract class ChannelsState extends Equatable {
  const ChannelsState();

  @override
  List<Object> get props => [];
}

/// حالة التحميل
class ChannelsLoading extends ChannelsState {
  const ChannelsLoading();
}

/// حالة التحميل الناجح
class ChannelsLoaded extends ChannelsState {
  final List<Channel> channels;
  final List<Channel> radioChannels;

  const ChannelsLoaded({
    required this.channels,
    required this.radioChannels,
  });

  @override
  List<Object> get props => [channels, radioChannels];
}

/// حالة الخطأ
class ChannelsError extends ChannelsState {
  final String message;

  const ChannelsError(this.message);

  @override
  List<Object> get props => [message];
}

/// Cubit لإدارة حالة القنوات
class ChannelsCubit extends Cubit<ChannelsState> {
  final ChannelRepository _repository;

  ChannelsCubit(this._repository) : super(const ChannelsLoading()) {
    loadChannels();
  }

  /// تحميل القنوات التلفزيونية والإذاعية
  Future<void> loadChannels() async {
    try {
      emit(const ChannelsLoading());

      final channels = await _repository.getChannels();
      final radioChannels = await _repository.getRadioChannels();

      emit(ChannelsLoaded(
        channels: channels,
        radioChannels: radioChannels,
      ));
    } catch (e) {
      emit(ChannelsError(
        'فشل تحميل القنوات: ${e.toString()}',
      ));
    }
  }

  /// إعادة تحميل القنوات
  Future<void> refreshChannels() async {
    await loadChannels();
  }

  /// الحصول على قناة حسب ID
  Future<Channel?> getChannelById(String id) async {
    if (state is ChannelsLoaded) {
      final loadedState = state as ChannelsLoaded;
      try {
        return loadedState.channels.firstWhere(
          (channel) => channel.id == id,
          orElse: () => loadedState.radioChannels.firstWhere(
            (channel) => channel.id == id,
            orElse: () => throw Exception('Channel not found'),
          ),
        );
      } catch (e) {
        // إذا لم نجدها في الحالة المحملة، نبحث في Repository
        return await _repository.getChannelById(id);
      }
    }
    // إذا لم تكن القنوات محملة، نبحث مباشرة في Repository
    return await _repository.getChannelById(id);
  }
}

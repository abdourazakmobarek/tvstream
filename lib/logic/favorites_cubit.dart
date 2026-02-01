import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State
class FavoritesState extends Equatable {
  final List<String> favoriteIds;

  const FavoritesState({this.favoriteIds = const []});

  @override
  List<Object> get props => [favoriteIds];
}

// Cubit
class FavoritesCubit extends Cubit<FavoritesState> {
  final SharedPreferences _prefs;

  FavoritesCubit(this._prefs) : super(const FavoritesState()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = _prefs.getStringList('favorite_channel_ids') ?? [];
    emit(FavoritesState(favoriteIds: ids));
  }

  Future<void> toggleFavorite(String channelId) async {
    final currentIds = List<String>.from(state.favoriteIds);
    
    if (currentIds.contains(channelId)) {
      currentIds.remove(channelId);
    } else {
      currentIds.add(channelId);
    }

    await _prefs.setStringList('favorite_channel_ids', currentIds);
    emit(FavoritesState(favoriteIds: currentIds));
  }
  
  bool isFavorite(String channelId) => state.favoriteIds.contains(channelId);
}

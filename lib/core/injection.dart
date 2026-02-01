import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/channel_data_source.dart';
import '../data/datasources/local_channel_data_source.dart';
import '../data/repositories/channel_repository.dart';
import '../logic/channels_cubit.dart';
import '../logic/favorites_cubit.dart';
import '../logic/localization_cubit.dart';

final getIt = GetIt.instance;

/// تهيئة حقن التبعيات
Future<void> setupDependencyInjection() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Data Sources
  getIt.registerLazySingleton<ChannelDataSource>(
    () => LocalChannelDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<ChannelRepository>(
    () => ChannelRepository(getIt<ChannelDataSource>()),
  );

  // Cubits - استخدام registerLazySingleton لأن BlocProvider يحتاج إلى مثيل واحد فقط
  // ويمكن الوصول إليها من أي مكان في التطبيق
  getIt.registerLazySingleton<LocalizationCubit>(() => LocalizationCubit());
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ChannelsCubit>(
    () => ChannelsCubit(getIt<ChannelRepository>()),
  );
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_prefs_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPrefs(Ref ref) async {
  return await SharedPreferences.getInstance();
}

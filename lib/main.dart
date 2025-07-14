import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartest_man/features/blocks/data/blocks_api/blocks_api.dart';

import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await SharedPreferences.getInstance();

  final packsApi = PacksApiImpl(prefs: database);

  bootstrap(packsApi: packsApi);
}

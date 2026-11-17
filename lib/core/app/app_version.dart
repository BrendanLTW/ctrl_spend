import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version.g.dart';

/// The app's version from pubspec.yaml, e.g. "1.0.0" (S21's footer).
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;

/// "1.0" for "1.0.0": the footer shows major and minor.
String shortVersion(String version) => version.split('.').take(2).join('.');

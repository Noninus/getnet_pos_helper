import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'getnet_pos_helper_platform_interface.dart';

/// An implementation of [GetnetPosHelperPlatform] that uses method channels.
class MethodChannelGetnetPosHelper extends GetnetPosHelperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('getnet_pos_helper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'getnet_pos_helper_method_channel.dart';

abstract class GetnetPosHelperPlatform extends PlatformInterface {
  /// Constructs a GetnetPosHelperPlatform.
  GetnetPosHelperPlatform() : super(token: _token);

  static final Object _token = Object();

  static GetnetPosHelperPlatform _instance = MethodChannelGetnetPosHelper();

  /// The default instance of [GetnetPosHelperPlatform] to use.
  ///
  /// Defaults to [MethodChannelGetnetPosHelper].
  static GetnetPosHelperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GetnetPosHelperPlatform] when
  /// they register themselves.
  static set instance(GetnetPosHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

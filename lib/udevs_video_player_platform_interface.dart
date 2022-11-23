import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'udevs_video_player_method_channel.dart';

abstract class UdevsVideoPlayerPlatform extends PlatformInterface {
  /// Constructs a UdevsVideoPlayerPlatform.
  UdevsVideoPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static UdevsVideoPlayerPlatform _instance = MethodChannelUdevsVideoPlayer();

  /// The default instance of [UdevsVideoPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelUdevsVideoPlayer].
  static UdevsVideoPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UdevsVideoPlayerPlatform] when
  /// they register themselves.
  static set instance(UdevsVideoPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> playVideo({required String playerConfigJsonString}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> downloadVideo({required String downloadConfigJsonString}) {
    throw UnimplementedError('downloadVideo() has not been implemented.');
  }

  Future<String?> pauseDownload({required String downloadConfigJsonString}) {
    throw UnimplementedError('pauseDownload() has not been implemented.');
  }

  Future<String?> resumeDownload({required String downloadConfigJsonString}) {
    throw UnimplementedError('resumeDownload() has not been implemented.');
  }

  Future<bool> isDownloadVideo({required String downloadConfigJsonString}) {
    throw UnimplementedError('isDownloadVideo() has not been implemented.');
  }

  Future<int?> getCurrentProgressDownload({required String downloadConfigJsonString}) {
    throw UnimplementedError('getCurrentProgressDownload() has not been implemented.');
  }

  Future<dynamic> closeVideo() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<int> currentProgressDownloadAsStream() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

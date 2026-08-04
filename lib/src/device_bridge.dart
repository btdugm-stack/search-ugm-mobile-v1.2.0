import 'package:flutter/services.dart';

class DeviceBridge {
  static const _channel = MethodChannel('id.ac.ugm.search/device');

  static Future<void> openUrl(String url) async {
    if (url.isEmpty) return;
    await _channel.invokeMethod<void>('openUrl', {'url': url});
  }

  static Future<List<String>> getHistory() async {
    final result = await _channel.invokeListMethod<String>('getHistory');
    return result ?? const [];
  }

  static Future<void> saveHistory(List<String> items) =>
      _channel.invokeMethod<void>('saveHistory', {'items': items.take(20).toList()});
}

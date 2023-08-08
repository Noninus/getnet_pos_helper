import 'package:flutter/services.dart';

class GetnetPos {
  static const MethodChannel _channel = MethodChannel('getnet_pos');

  /// Print a list of strings.
  /// Uses the qrCodePattern to match the qrCode. If matches the qrcode is printed.
  /// Uses the barcodePattern to match the barcode. If matches the barcode is printed.
  static Future<void> print(
    List<String> list, {
    String qrCodePattern = '(\\d{44}\\|.*\$)',
    String barcodePattern = '^\\d{1,}.\$',
    bool printBarcode = false,
  }) async =>
      await _channel.invokeMethod('print', {
        'list': list,
        'qrCodePattern': qrCodePattern,
        'barcodePattern': barcodePattern,
        'printBarcode': printBarcode,
      });

  /// Returns the card serial number from Mifare
  static Future<String> getMifareCardSN() async =>
      await _channel.invokeMethod('getMifare');

  /// Try scan for QRCode
  static Future<String> scan() async => await _channel.invokeMethod('scanner');

  /// Check service status
  static Future<String> checkService({
    String label = 'Service Status',
    String trueMessage = 'On',
    String falseMessage = 'Off',
  }) async {
    var initiated = await _channel.invokeMethod('check');
    return "$label: ${initiated ? trueMessage : falseMessage}";
  }

  /// Try to make payment
  static Future<String> payment(
          String amount, String paymentType, String callerId) async =>
      await _channel.invokeMethod('payment', {
        'amount': amount,
        // 'creditType': creditType, não precisa enviar caso não for parcelado
        'paymentType': paymentType,
        'callerId': callerId
      });
}

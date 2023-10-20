import 'dart:async';

import 'package:flutter/services.dart';
import 'package:getnet_pos_helper/payment_service/payment_response.dart';
import 'package:getnet_pos_helper/payment_service/payment_service.dart';

class GetnetPos {
  static const MethodChannel _channel = MethodChannel('getnet_pos');
  static final PaymentService _paymentService = PaymentService(_channel);

  static init() async {
    await initialize();
  }

  /// Print a list of strings.
  /// Uses the qrCodePattern to match the qrCode. If matches the qrcode is printed.
  /// Uses the barcodePattern to match the barcode. If matches the barcode is printed.
  static Future<void> printText(
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

  /// Print a list of strings.
  /// Uses the qrCodePattern to match the qrCode. If matches the qrcode is printed.
  /// Uses the barcodePattern to match the barcode. If matches the barcode is printed.
  static Future<void> printJumpLines(
    int numberRows, {
    String qrCodePattern = '(\\d{44}\\|.*\$)',
    String barcodePattern = '^\\d{1,}.\$',
    bool printBarcode = false,
  }) async {
    List<String> rows = [];

    for (var i = 0; i < numberRows; i++) {
      rows.add(" ");
    }

    await _channel.invokeMethod('print', {
      'list': rows,
      'qrCodePattern': qrCodePattern,
      'barcodePattern': barcodePattern,
      'printBarcode': printBarcode,
    });
  }

  /// Print a list of strings.
  /// Uses the qrCodePattern to match the qrCode. If matches the qrcode is printed.
  /// Uses the barcodePattern to match the barcode. If matches the barcode is printed.
  static Future<void> printImage(
    List<String> list, {
    int jumpLines = 4,
    String qrCodePattern = '(\\d{44}\\|.*\$)',
    String barcodePattern = '^\\d{1,}.\$',
    bool printBarcode = false,
  }) async {
    for (var i = 0; i < jumpLines; i++) {
      list.add(" ");
    }

    await _channel.invokeMethod('printImage', {
      'list': list,
      'qrCodePattern': qrCodePattern,
      'barcodePattern': barcodePattern,
      'printBarcode': printBarcode,
    });
  }

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

  /// Check service status
  static Future<String> initialize() async {
    var initiated = await _channel.invokeMethod('initialize');
    return "$initiated";
  }

  /// Try to make payment
  static checkout(String amount, String paymentType, String callerId) async {
    _paymentService.checkout(amount, paymentType, callerId);
  }

  /// Stream do checkout
  static Stream<GetNetPaymentResponse> get checkoutStreamListen =>
      _paymentService.streamData;
}

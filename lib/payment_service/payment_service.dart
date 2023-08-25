import 'dart:async';
import 'package:flutter/services.dart';
import 'package:getnet_pos_helper/payment_service/payment_response.dart';

class PaymentService {
  final MethodChannel _messagesChannel;

  static final StreamController<PaymentResponse> _controller =
      StreamController.broadcast();

  Stream<PaymentResponse> get streamData => _controller.stream;

  PaymentService(this._messagesChannel);

  checkout(String amount, String paymentType, String callerId) async {
    try {
      _messagesChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case "checkoutCallback":
            var uri = Uri.parse(call.arguments);
            PaymentResponse paymentResponse = PaymentResponse(
                code: uri.queryParameters['code'],
                amount: uri.queryParameters['amount'],
                itk: uri.queryParameters['itk'],
                type: uri.queryParameters['type'],
                installmentCount: uri.queryParameters['installment_count'],
                brand: uri.queryParameters['brand'],
                entryMode: uri.queryParameters['entry_mode'],
                atk: uri.queryParameters['atk'],
                pan: uri.queryParameters['pan'],
                authorizationCode: uri.queryParameters['authorization_code'],
                authorizationDateTime:
                    uri.queryParameters['authorization_date_time'],
                success:
                    uri.queryParameters['success'] == "true" ? true : false,
                message: uri.queryParameters['success'] == "true"
                    ? "OK"
                    : uri.queryParameters['message'],
                reason: uri.queryParameters['reason'],
                responseCode: uri.queryParameters['response_code']);
            _controller.add(paymentResponse);
            break;
          default:
        }
      });
    } on PlatformException catch (e) {
      _controller.add(PaymentResponse(
          success: false,
          message: e.toString(),
          reason: "platError",
          responseCode: "9999"));
    }
    try {
      await _messagesChannel.invokeMethod('payment', {
        'amount': amount,
        // 'creditType': creditType, não precisa enviar caso não for parcelado
        'paymentType': paymentType,
        'callerId': callerId
      });
    } on PlatformException catch (e) {
      _controller.add(PaymentResponse(
          success: false,
          message: e.toString(),
          reason: "erro ao enviar deeplink",
          responseCode: "9998"));
    }
  }
}

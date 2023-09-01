import 'dart:async';
import 'package:flutter/services.dart';
import 'package:getnet_pos_helper/payment_service/payment_response.dart';

class PaymentService {
  final MethodChannel _messagesChannel;

  static final StreamController<GetNetPaymentResponse> _controller =
      StreamController.broadcast();

  Stream<GetNetPaymentResponse> get streamData => _controller.stream;

  PaymentService(this._messagesChannel);

  checkout(String amount, String paymentType, String callerId) async {
    try {
      const MethodChannel("sagres_mobile_channel")
          .setMethodCallHandler((call) async {
        switch (call.method) {
          case "checkoutCallback":
            GetNetPaymentResponse paymentResponse = GetNetPaymentResponse(
                code: call.arguments['code'],
                amount: call.arguments['amount'],
                itk: call.arguments['itk'],
                type: call.arguments['type'],
                installmentCount: call.arguments['installment_count'],
                brand: call.arguments['brand'],
                entryMode: call.arguments['entry_mode'],
                atk: call.arguments['atk'],
                pan: call.arguments['pan'],
                authorizationCode: call.arguments['authorization_code'],
                authorizationDateTime:
                    call.arguments['authorization_date_time'],
                success: call.arguments['success'] == "true" ? true : false,
                message: call.arguments['success'] == "true"
                    ? "OK"
                    : call.arguments['message'],
                reason: call.arguments['reason'],
                responseCode: call.arguments['response_code']);
            _controller.add(paymentResponse);
            break;
          default:
        }
      });
    } on PlatformException catch (e) {
      _controller.add(GetNetPaymentResponse(
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
      _controller.add(GetNetPaymentResponse(
          success: false,
          message: e.toString(),
          reason: "erro ao enviar deeplink",
          responseCode: "9998"));
    }
  }
}

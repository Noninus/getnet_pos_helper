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
            List<String> arguments = call.arguments.toString().split(',');
            GetNetPaymentResponse paymentResponse = GetNetPaymentResponse(
              result: arguments[0],
              resultDetails: arguments[1],
              amount: arguments[2],
              callerId: arguments[3],
              nsu: arguments[4],
              nsuLastSuccesfullMessage: arguments[5],
              cvNumber: arguments[6],
              type: arguments[7],
              brand: arguments[8],
              inputType: arguments[9],
              installments: arguments[10],
              gmtDateTime: arguments[11],
              nsuLocal: arguments[12],
              authorizationCode: arguments[13],
              cardBin: arguments[14],
              cardLastDigits: arguments[15],
              extraScreensResult: arguments[16],
              cardholderName: arguments[17],
              automationSlip: arguments[18],
              printMerchantPreference: arguments[19],
              orderId: arguments[20],
              pixPayloadResponse: arguments[21],
            );
            _controller.add(paymentResponse);
            break;
          default:
        }
      });
    } on PlatformException catch (e) {
      _controller.add(GetNetPaymentResponse(
        result: "erro",
        resultDetails: e.toString(),
      ));
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
        result: "erro",
        resultDetails: e.toString(),
      ));
    }
  }
}

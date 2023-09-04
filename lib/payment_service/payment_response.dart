class GetNetPaymentResponse {
  String? result;
  String? resultDetails;
  String? amount;
  String? callerId;
  String? nsu;
  String? nsuLastSuccesfullMessage;
  String? cvNumber;
  String? type;
  String? brand;
  String? inputType;
  String? installments;
  String? gmtDateTime;
  String? nsuLocal;
  String? authorizationCode;
  String? cardBin;
  String? cardLastDigits;
  String? extraScreensResult;
  String? cardholderName;
  String? automationSlip;
  String? printMerchantPreference;
  String? orderId;
  String? pixPayloadResponse;

  GetNetPaymentResponse({
    this.result,
    this.resultDetails,
    this.amount,
    this.callerId,
    this.nsu,
    this.nsuLastSuccesfullMessage,
    this.cvNumber,
    this.type,
    this.brand,
    this.inputType,
    this.installments,
    this.gmtDateTime,
    this.nsuLocal,
    this.authorizationCode,
    this.cardBin,
    this.cardLastDigits,
    this.extraScreensResult,
    this.cardholderName,
    this.automationSlip,
    this.printMerchantPreference,
    this.orderId,
    this.pixPayloadResponse,
  });
}

class PaymentResponse {
  String? code;
  String? amount;
  String? itk;
  String? type;
  String? installmentCount;
  String? brand;
  String? entryMode;
  String? atk;
  String? pan;
  String? authorizationCode;
  String? authorizationDateTime;
  bool? success;
  String? reason;
  String? responseCode;
  String? message;

  PaymentResponse({
    this.code,
    this.amount,
    this.itk,
    this.type,
    this.installmentCount,
    this.brand,
    this.entryMode,
    this.atk,
    this.pan,
    this.authorizationCode,
    this.authorizationDateTime,
    this.success,
    this.reason,
    this.responseCode,
    this.message,
  });

  PaymentResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    amount = json['amount'];
    itk = json['itk'];
    type = json['type'];
    installmentCount = json['installment_count'];
    brand = json['brand'];
    entryMode = json['entry_mode'];
    atk = json['atk'];
    pan = json['pan'];
    authorizationCode = json['authorization_code'];
    authorizationDateTime = json['authorization_date_time'];
    success = json['success'];
    reason = json['reason'];
    responseCode = json['response_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['amount'] = amount;
    data['itk'] = itk;
    data['type'] = type;
    data['installmentCount'] = installmentCount;
    data['brand'] = brand;
    data['entryMode'] = entryMode;
    data['atk'] = atk;
    data['pan'] = pan;
    data['authorization_code'] = authorizationCode;
    data['authorization_date_time'] = authorizationDateTime;

    data['success'] = success;
    data['reason'] = reason;
    data['response_code'] = responseCode;
    data['message'] = message;
    return data;
  }
}

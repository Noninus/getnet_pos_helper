package br.com.sagresinformatica.getnet_pos_helper;

import android.content.Context;
import android.os.RemoteException;

import com.getnet.posdigital.PosDigital;
import com.getnet.posdigital.camera.ICameraCallback;
import com.getnet.posdigital.mifare.IMifareCallback;
import com.getnet.posdigital.printer.AlignMode;
import com.getnet.posdigital.printer.FontFormat;
import com.getnet.posdigital.printer.IPrinterCallback;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Intent;
import android.os.Bundle;
import android.net.Uri;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import android.app.Activity;
import androidx.annotation.NonNull;
import android.util.Log;

import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import android.util.Base64;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

/**
 * GetnetPosHelperPlugin
 */
public class GetnetPosHelperPlugin implements ActivityAware, FlutterPlugin, MethodCallHandler  {

    private Activity activity;
    private static MethodChannel channel;

    private static final Logger LOGGER = Logger.getLogger(GetnetPosHelperPlugin.class.getName());
    private static final String QR_CODE_PATTERN = "qrCodePattern";
    private static final String BARCODE_PATTERN = "barcodePattern";
    private static final String PRINT_BARCODE = "printBarcode";
    private static final String LIST = "list";
    private static Context context;

    private final int REQUEST_CODE = 1001;
    private final String ARG_RESULT = "result";
    private final String ARG_RESULT_DETAILS = "resultDetails";
    private final String ARG_AMOUNT = "amount";
    private final String ARG_TYPE = "type";
    private final String ARG_INPUT_TYPE = "inputType";
    private final String ARG_INSTALLMENTS = "installments";
    private final String ARG_NSU = "nsu";
    private final String ARG_BRAND = "brand";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "getnet_pos");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
        activityPluginBinding.addOnNewIntentListener(new NewIntentListener() {
            @Override
            public boolean onNewIntent(Intent intent) {
                LOGGER.log(Level.SEVERE, "onNewIntent");
                handleDeepLinkResponse(intent);
                return false;
                // Lógica a ser executada quando um novo intent for recebido
            }
        });
        handleDeepLinkResponse(this.activity.getIntent());
    }
  
    @Override
    public void onDetachedFromActivityForConfigChanges() {
      this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
       onAttachedToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }

    /**
     * Init the PosDigital Hardware SDK
     */
    private void ensureInitialized(final Callback callback) {
        try {
            LOGGER.info("Checking service");
            if (!PosDigital.getInstance().isInitiated()) {
                LOGGER.log(Level.SEVERE, "Instance exists, but mainService is null.");
                callback.onError("PosDigital service is not initialized.");
            } else {
                LOGGER.info("PosDigital is registered. Performing action");
                callback.performAction();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "PosDigital not registered yet, trying now. "+e.getMessage());
            registerPosDigital(callback);
        }
    }

    private void registerPosDigital(final Callback callback) {
        try {
            PosDigital.register(context, new PosDigital.BindCallback() {
                @Override
                public void onError(Exception e) {
                    callback.onError(e.getMessage());
                }

                @Override
                public void onConnected() {
                    LOGGER.log(Level.SEVERE, "onConnected");
                    try {
                        callback.performAction();
                    } catch (Exception e) {
                        callback.onError(e.getMessage());
                    }
                }

                @Override
                public void onDisconnected() {
                    LOGGER.info("PosDigital service getnet disconnected");
                }
            });
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Exception e");
            callback.onError("Failure on service initialization" + e.getMessage());
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        print(call, result);
        getMifare(call, result, 10);
        scanner(call, result);
        checkService(call, result);
        payment(call, result);
        initialize(call, result);
        printImage(call, result);
    }

    /**
     * Check if the service is initialized
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void checkService(MethodCall call, Result result) {
        LOGGER.log(Level.SEVERE, "checkService: ");
        if (call.method.equals("check")) {
            boolean initiated = false;
            try {
                initiated = PosDigital.getInstance().isInitiated();
                PosDigital.getInstance().getBeeper().success();
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failure when checking service: " + e.getMessage());
            }
            result.success(initiated);
        }
    }

    /**
     * initialize method
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void initialize(MethodCall call, Result result) {
        LOGGER.log(Level.SEVERE, "initialize");
        if (call.method.equals("initialize")) {
            registerPosDigital(new Callback() {
                @Override
                public void performAction() {
                    LOGGER.info("Initialized!");
                }

                @Override
                public void onError(String message) {
                    LOGGER.info("GetnetPosHelperPlugin onError");
                    LOGGER.log(Level.SEVERE, message);
                }
            });
        }
    }

    /**
     * Make payment
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void payment(MethodCall call, Result result) {
        if (call.method.equals("payment")) {
            Bundle bundle = new Bundle();
            bundle.putString("amount", call.argument("amount"));
            bundle.putString("paymentType", call.argument("paymentType"));
            bundle.putString("callerId", call.argument("callerId"));
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("getnet://pagamento/v3/payment"));
            intent.putExtras(bundle);
            intent.putExtra("return_scheme", "payment_response");
            intent.putExtra("urlCallback", "payment_response");
            this.activity.startActivityForResult(intent, REQUEST_CODE);
            LOGGER.log(Level.SEVERE, "payment");
            result.success(true);
        }
    }

    private void handleDeepLinkResponse(Intent intent) {
        LOGGER.log(Level.SEVERE, "handleDeepLinkResponse");
        Log.v("SendDeeplinkPayment", "handleDeepLinkResponse");
        channel.invokeMethod("checkoutCallback", intent.toString());
        
    }

    /**
     * Print
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void print(final MethodCall call, final Result result) {
        if (call.method.equals("print")) {
            ensureInitialized(new Callback() {
                @Override
                public void performAction() {
                    List<String> lines = call.argument(LIST);
                    String qrCodePattern = call.argument(QR_CODE_PATTERN);
                    String barCodePattern = call.argument(BARCODE_PATTERN);
                    boolean printBarcode = call.argument(PRINT_BARCODE);
                    if (lines != null && !lines.isEmpty()) {
                        try {
                            addTextToPrinter(lines, qrCodePattern, barCodePattern, printBarcode);
                            callPrintMethod(result);
                        } catch (Exception e) {
                            result.error("Error on print", e.getMessage(), null);
                        }
                    } else {
                        result.error("Arguments are missed [list, qrCodePattern, barcodePattern]", null, null);
                    }
                }

                @Override
                public void onError(String message) {
                    result.error("print", message, null);
                }
            });
        }
    }

    /**
     * Print
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void printImage(final MethodCall call, final Result result) {
        if (call.method.equals("printImage")) {
            ensureInitialized(new Callback() {
                @Override
                public void performAction() {
                    List<String> lines = call.argument(LIST);
                    String qrCodePattern = call.argument(QR_CODE_PATTERN);
                    String barCodePattern = call.argument(BARCODE_PATTERN);
                    boolean printBarcode = call.argument(PRINT_BARCODE);
                    if (lines != null && !lines.isEmpty()) {
                        try {
                            addImageToPrinter(lines, qrCodePattern, barCodePattern, printBarcode);
                            callPrintMethod(result);
                        } catch (Exception e) {
                            result.error("Error on print", e.getMessage(), null);
                        }
                    } else {
                        result.error("Arguments are missed [list, qrCodePattern, barcodePattern]", null, null);
                    }
                }

                @Override
                public void onError(String message) {
                    result.error("print", message, null);
                }
            });
        }
    }

    /**
     * Invoke print method and set status of operation on result callback
     *
     * @param result - result for handler the status
     * @throws RemoteException - if the printer is not available
     */
    private void callPrintMethod(final Result result) throws RemoteException {
        PosDigital.getInstance().getPrinter().print(new IPrinterCallback.Stub() {
            @Override
            public void onSuccess() {
                result.success("Printed.");
            }

            @Override
            public void onError(int i) {
                result.error("Error code: " + i, null, null);
            }
        });
    }

    /**
     * Add a list of string to the printer buffer
     *
     * @param lines - linest to be printed
     * @throws RemoteException - if printer is not available
     */
    private void addTextToPrinter(List<String> lines, String qrCodePattern, String barcodePattern, boolean printBarCode) throws RemoteException {
        PosDigital.getInstance().getPrinter().init();
        PosDigital.getInstance().getPrinter().setGray(5);
        PosDigital.getInstance().getPrinter().defineFontFormat(FontFormat.SMALL);
        PosDigital.getInstance().getPrinter().addText(AlignMode.CENTER, lines.remove(0));
        Pattern patternQrCode = Pattern.compile(qrCodePattern, Pattern.MULTILINE);
        Pattern patternBarCode = Pattern.compile(barcodePattern, Pattern.MULTILINE);
        for (String text : lines) {
            for (String line : text.split("\n")) {
                Matcher qrcodeMatcher = patternQrCode.matcher(line);
                Matcher barcodeMather = patternBarCode.matcher(line);
                if (qrcodeMatcher.find()) {
                    PosDigital.getInstance().getPrinter().addQrCode(AlignMode.CENTER, 360, line);
                } else if (printBarCode && barcodeMather.find()) {
                    PosDigital.getInstance().getPrinter().addText(AlignMode.CENTER, line);
                    PosDigital.getInstance().getPrinter().addBarCode(AlignMode.CENTER, line.trim());
                    PosDigital.getInstance().getPrinter().addText(AlignMode.CENTER, "");
                } else {
                    PosDigital.getInstance().getPrinter().addText(AlignMode.LEFT, line);
                }
            }
        }
    }

    /**
     * Add a list of string to the printer buffer
     *
     * @param lines - linest to be printed
     * @throws RemoteException - if printer is not available
     */
    private void addImageToPrinter(List<String> lines, String qrCodePattern, String barcodePattern, boolean printBarCode) throws RemoteException {
        PosDigital.getInstance().getPrinter().init();
        for (String text : lines) {
            for (String line : text.split("\n")) {
                byte[] decodedString = Base64.decode(line, Base64.DEFAULT);
                Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                PosDigital.getInstance().getPrinter().addImageBitmap(AlignMode.CENTER, decodedByte);
            }
        }
    }

    /**
     * Try to read a next card
     *
     * @param call        - method call
     * @param result      - result callback
     * @param remainTries - number of tries
     */
    private void getMifare(final MethodCall call, final Result result, final int remainTries) {
        if (call.method.equals("getMifare")) {
            ensureInitialized(new Callback() {
                @Override
                public void performAction() {
                    try {
                        PosDigital.getInstance().getMifare().searchCard(new IMifareCallback.Stub() {
                            @Override
                            public void onCard(int i) throws RemoteException {
                                result.success(PosDigital.getInstance().getMifare().getCardSerialNo(i));
                                PosDigital.getInstance().getMifare().halt();
                            }

                            @Override
                            public void onError(String s) throws RemoteException {
                                if (remainTries > 0) {
                                    getMifare(call, result, remainTries - 1);
                                } else {
                                    result.error("Error on Mifare", s, null);
                                }
                            }
                        });
                    } catch (Exception e) {
                        result.error("Error", e.getMessage(), null);
                    }
                }

                @Override
                public void onError(String message) {
                    result.error("getMifare", message, null);
                }
            });
        }
    }

    /**
     * Try read some barcode/qrcode using the back camera
     *
     * @param call   - method call
     * @param result - result callback
     */
    private void scanner(final MethodCall call, final Result result) {
        if (call.method.equals("scanner")) {
            ensureInitialized(new Callback() {
                @Override
                public void performAction() {
                    try {
                        PosDigital.getInstance().getCamera().readBack(5000, new ICameraCallback.Stub() {
                            @Override
                            public void onSuccess(String s) throws RemoteException {
                                LOGGER.info("Info obtained from scanner: " + s);
                                result.success(s);
                            }

                            @Override
                            public void onTimeout() throws RemoteException {
                                result.error("Timeout Error", "Timeout expired", null);
                            }

                            @Override
                            public void onCancel() throws RemoteException {
                                result.error("Cancelled", "Cancelled by the user", null);
                            }

                            @Override
                            public void onError(String s) throws RemoteException {
                                result.error("Error on scanner", s, null);
                            }
                        });
                    } catch (Exception e) {
                        result.error("Error", e.getMessage(), null);
                    }
                }

                @Override
                public void onError(String message) {
                    result.error("scanner", message, null);
                }
            });
        }
    }

    private interface Callback {
        void performAction();

        void onError(String message);
    }

}

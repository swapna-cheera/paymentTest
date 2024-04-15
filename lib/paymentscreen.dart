import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Amount:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle payment logic here (e.g., make API call)
                _makePayment();
              },
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder method for making the payment API call
  void _makePayment() async {
    Map<String, dynamic> jsonDeviceData =
        await PaymentApi().fetchDeviceInfoData();

    var params = {
      "mercid": 'merchant ID',
      "orderid": "EENADU12345678", //"TSSGF432f15G",
      "amount": '100.00',
      "order_date": DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now()),
      "currency": "356",
      "ru": "",
      "additional_info": {
        // "additional_info1": userId,
        // "additional_info2": packageId
      },
      "itemcode": "DIRECT",
      "device": jsonDeviceData
    };

    String traceID = "ABCId83840JSN303";

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final PaymentApi apiService = PaymentApi();

      http.Response? baseResponse = await apiService.billDeskCreateOrderAPI(
        traceID,
        timeStamp,
        params,
      );
      if (baseResponse?.statusCode == 200) {
        debugPrint('Success Response');
      } else {
        debugPrint('Error Response ');
      }
    } catch (error) {
      debugPrint('Error is $error');
    }
  }
}

class PaymentApi {
  Future<http.Response?> billDeskCreateOrderAPI(
    String traceId,
    String timeStamp,
    Map<String, dynamic> jsonBody,
  ) async {
    try {
      Uri apiUrl = Uri.https(
        'https://uat1.billdesk.com/u2/payments/ve1_2/orders/create',
      );
      debugPrint(apiUrl.toString());
      debugPrint(jsonBody.toString());

      //  JWS header and payload
      Map<String, dynamic> algoClientId = {
        "alg": "HS256",
        "clientid": 'Place CLIENT ID',
      };

      debugPrint('\n algoClientId $algoClientId \n');
      debugPrint('JSON Body $jsonBody \n');

      // Convert the header and payload to JSON strings
      // String encodedHeader = json.encode(header);
      // String encodedPayload = json.encode(jsonBody);

      // debugPrint('\n encodedHeader $encodedHeader \n');
      // debugPrint('encodedPayload $encodedPayload \n');

      // Sign the JWS header and payload using the secret key
      //Replace JWS-HMAC token here
      String signedJWS = "";

      var response = await http.post(
        apiUrl,
        body: signedJWS,
        headers: {
          'Content-type': 'application/jose',
          'Accept': 'application/jose',
          'BD-Traceid': traceId,
          "BD-Timestamp": timeStamp,
        },
      );
      debugPrint('\n Headers are ${response.headers} \n');
      debugPrint('JSON Body is $jsonBody \n');
      String responseBody = utf8.decoder.convert(response.bodyBytes);
      debugPrint('Url is $apiUrl \n $responseBody');
      return response;
    } catch (e) {
      debugPrint('Erros is ==> ${e.toString()} \n');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchDeviceInfoData() async {
    // Fetch IP address
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    String ipAddress = response.body;

    // Fetch screen dimensions
    // MediaQueryData mediaQueryData =
    //     MediaQueryData.fromView(WidgetsBinding.instance.window);
    // double screenWidth = mediaQueryData.size.width;
    // double screenHeight = mediaQueryData.size.height;

    // Fill in JSON data based on platform
    Map<String, dynamic> jsonData = {
      "init_channel": "internet",
      "ip": ipAddress,
      "user_agent": Platform.isAndroid ? "Android" : "iOS",
      // "accept_header": "text/html",
      // "fingerprintid": "61b12c18b5d0cf901be34a23ca64bb19",
      // "browser_tz": "-330",
      // "browser_color_depth": "32",
      // "browser_java_enabled": false,
      // "browser_screen_height": screenHeight.toString(),
      // "browser_screen_width": screenWidth.toString(),
      // "browser_language": Platform.localeName,
      // "browser_javascript_enabled": true
    };

    debugPrint(jsonData.toString());
    return jsonData;
  }
}

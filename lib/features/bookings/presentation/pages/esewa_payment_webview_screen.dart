import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EsewaPaymentWebViewScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const EsewaPaymentWebViewScreen({super.key, required this.paymentData});

  @override
  State<EsewaPaymentWebViewScreen> createState() => _EsewaPaymentWebViewScreenState();
}

class _EsewaPaymentWebViewScreenState extends State<EsewaPaymentWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final data = widget.paymentData;

    // Build HTML with actual interpolated values (no escaping!)
    final esewaUrl = data['ESEWA_URL'];
    final amount = data['amount'];
    final taxAmount = data['tax_amount'];
    final totalAmount = data['total_amount'];
    final transactionUuid = data['transaction_uuid'];
    final productCode = data['product_code'];
    final productServiceCharge = data['product_service_charge'];
    final productDeliveryCharge = data['product_delivery_charge'];
    final successUrl = data['success_url'];
    final failureUrl = data['failure_url'];
    final signedFieldNames = data['signed_field_names'];
    final signature = data['signature'];

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { display: flex; justify-content: center; align-items: center; height: 100vh; font-family: sans-serif; margin: 0; background-color: #f4f4f4;}
    .loader { border: 4px solid #f3f3f3; border-top: 4px solid #4CAF50; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin-bottom: 20px;}
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .container { text-align: center; }
  </style>
</head>
<body onload="document.forms[0].submit()">
  <div class="container">
    <div class="loader"></div>
    <h2>Redirecting to eSewa...</h2>
  </div>
  <form action="$esewaUrl" method="POST" style="display: none;">
    <input type="hidden" name="amount" value="$amount">
    <input type="hidden" name="tax_amount" value="$taxAmount">
    <input type="hidden" name="total_amount" value="$totalAmount">
    <input type="hidden" name="transaction_uuid" value="$transactionUuid">
    <input type="hidden" name="product_code" value="$productCode">
    <input type="hidden" name="product_service_charge" value="$productServiceCharge">
    <input type="hidden" name="product_delivery_charge" value="$productDeliveryCharge">
    <input type="hidden" name="success_url" value="$successUrl">
    <input type="hidden" name="failure_url" value="$failureUrl">
    <input type="hidden" name="signed_field_names" value="$signedFieldNames">
    <input type="hidden" name="signature" value="$signature">
  </form>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Let the success URL go through — it hits the backend /verify endpoint
            // which actually updates the database. We catch it in onPageFinished.
            if (request.url.startsWith(failureUrl)) {
              Navigator.pop(context, {'status': 'failure', 'url': request.url});
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            // After the backend verify endpoint finishes loading, pop with success
            if (url.startsWith(successUrl)) {
              Navigator.pop(context, {'status': 'success', 'url': url});
            }
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF60A917), // eSewa green
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

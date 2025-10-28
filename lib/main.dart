import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remicon_service_web_app/util/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  // }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // 원하는 배경색
      statusBarIconBrightness:
          Brightness.light, // 아이콘 색상 (light = 흰색, dark = 검정)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XiRtis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            appPrintI(request.url);
            appPrintC(
                'check weather: ${request.url.contains("www.weather.go.kr")}');

            // weather: external browser
            if (request.url.contains("www.weather.go.kr")) {
              appPrintC('enter:www.weather.go.kr');
              await launchUrl(Uri.parse(request.url),
                  mode: LaunchMode.externalApplication);

              return NavigationDecision.prevent;
            }
            // tel
            if (request.url.startsWith('tel')) {
              if (await canLaunchUrl(Uri.parse(request.url))) {
                final phoneNumber =
                    request.url.toString().replaceAll(RegExp(r'[^0-9]'), '');
                if (phoneNumber.contains('tel')) {
                  await launchUrlString(phoneNumber);
                } else {
                  await launchUrlString('tel:$phoneNumber');
                }
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
        // 'http://10.51.168.128:3000/'
          // 'https://m-rtis-pilot-dev.gsenc.com'
          'https://m-rtis-pilot.gsenc.com'
          ));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: SafeArea(child: WebViewWidget(controller: controller)),
        ));
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

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
      title: 'Flutter Demo',
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
        ),
        body: SafeArea(
            child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(
              // 'http://10.51.168.128:3000'
              'https://m-rtis-pilot.gsenc.com/login')),
          initialSettings: InAppWebViewSettings(
            // isInspectable: kWebviewDebug,
            // userAgent: kUserAgentForFmcs,
            //
            allowsBackForwardNavigationGestures: true,
            allowFileAccess: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            allowsInlineMediaPlayback: true,
            allowsLinkPreview: false,
            // enableViewportScale: false,
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            supportZoom: true,
            useHybridComposition: true,
            useShouldOverrideUrlLoading: true,
            useWideViewPort: true,
            useOnDownloadStart: true,
            //
            // clearCache: _clearCache,
            // clearSessionCache: _clearSession,
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            Uri uri = navigationAction.request.url!;

            // weather: external browser
            if (uri.toString().contains("www.weather.go.kr")) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationActionPolicy.CANCEL;
            }

            // tel
            if (uri.isScheme('tel')) {
              if (await canLaunchUrl(uri)) {
                final phoneNumber =
                    uri.toString().replaceAll(RegExp(r'[^0-9]'), '');
                if (phoneNumber.contains('tel')) {
                  await launchUrlString(phoneNumber);
                } else {
                  await launchUrlString('tel:$phoneNumber');
                }
              }
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        )));
  }
}

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:remicon_service_web_app/util/app_logger.dart';
import 'package:remicon_service_web_app/util/app_packageinfo.dart';
import 'package:remicon_service_web_app/util/urlhelper.dart';
import 'package:remicon_service_web_app/util/webviewHelper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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
      home: MyHomePage(),
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
  _MyHomePageState() : currentMode = kDebugMode ? 'LOCAL' : 'PRO';
  final String currentMode;

  String appUri = '';

  InAppWebViewController? controller;
  Key _webviewKey = UniqueKey();

  @override
  void initState() {
    appUri = dotenv.env['${currentMode}_URL'] ?? '';
    AppLinks().uriLinkStream.listen((uri) async {
      appPrintC('onAppLink: $uri');
      final parsingUri = uri.toString().split('target=');
      appUri = Urlhelper.adjustUrl(parsingUri[1]);
      appPrintC('appUri:$appUri');

      if (controller != null) {
        _webviewKey = UniqueKey();
        await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(appUri)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget =
        Center(child: Lottie.asset('assets/lotties/loading.json'));

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
        ),
        body: FutureBuilder(
            future: AppPackageinfo.getAppVersion(),
            builder: (context, asyncSnapshot) {
              return SafeArea(
                  child: (asyncSnapshot.data == null)
                      ? loadingWidget
                      : webviewWiget(asyncSnapshot.data!));
            }));
  }

  Widget webviewWiget(String appVersion) {
    final webviewhelper = Webviewhelper();
    return InAppWebView(
        key: _webviewKey,
        initialUrlRequest: URLRequest(url: WebUri(appUri)),
        initialSettings: webviewhelper.initialSettings(appVersion),
        onWebViewCreated: (webController) => controller = webController,
        shouldOverrideUrlLoading: webviewhelper.shouldOverrideUrlLoading);
  }
}

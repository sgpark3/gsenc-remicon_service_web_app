import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:remicon_service_web_app/util/app_logger.dart';
import 'package:remicon_service_web_app/util/app_packageinfo.dart';
import 'package:remicon_service_web_app/util/urlhelper.dart';
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
  String appUri = 'http://10.51.168.128:3000';
  InAppWebViewController? controller;
Key _webviewKey = UniqueKey();

  @override
  void initState() {
    AppLinks().uriLinkStream.listen((uri) async {
      appPrintC('onAppLink: $uri');
      final parsingUri = uri.toString().split('target=');
      appUri =Urlhelper.adjustUrl(parsingUri[1]);
      appPrintC('appUri:$appUri');

    
      if (controller != null) {
        _webviewKey=UniqueKey();
        await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(appUri)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      ? Text('...laoding')
                      : InAppWebView(
                        key:_webviewKey,
                          initialUrlRequest: URLRequest(url: WebUri(appUri)),
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
                              userAgent: 'xirtis:${asyncSnapshot.data}'
                              //
                              // clearCache: _clearCache,
                              // clearSessionCache: _clearSession,
                              ),
                          onWebViewCreated: (webController) =>
                              controller = webController,
                          shouldOverrideUrlLoading:
                              (controller, navigationAction) async {
                            Uri uri = navigationAction.request.url!;

                            // external browser
                            if (uri.toString().contains('externalbrowser://')) {
                              final str = uri.toString();
                              String newStrUrl =
                                  str.replaceAll('externalbrowser://', '');
                              if (!newStrUrl.contains('https:')) {
                                newStrUrl =
                                    newStrUrl.replaceAll('https', 'https:');
                              }

                              final extractUri = Uri.parse(newStrUrl);

                              if (await canLaunchUrl(extractUri)) {
                                await launchUrl(extractUri,
                                    mode: LaunchMode.externalApplication);
                              }
                              return NavigationActionPolicy.CANCEL;
                            }

                            // tel
                            if (uri.isScheme('tel')) {
                              if (await canLaunchUrl(uri)) {
                                final phoneNumber = uri
                                    .toString()
                                    .replaceAll(RegExp(r'[^0-9]'), '');
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
                        ));
            }));
  }
}

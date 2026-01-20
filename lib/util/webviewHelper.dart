import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:remicon_service_web_app/util/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Webviewhelper {
  const Webviewhelper();

  InAppWebViewSettings initialSettings(String appVersion) {
    return InAppWebViewSettings(
        // isInspectable: kWebviewDebug,
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
        applicationNameForUserAgent: 'xirtis:$appVersion'
        //
        // clearCache: _clearCache,
        // clearSessionCache: _clearSession,
        );
  }

  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    Uri uri = navigationAction.request.url!;

    if (uri.toString().contains('externalbrowser://')) {
      return externalbrowser(uri);
    }
    if (uri.isScheme('tel')) {
      return callPhone(uri);
    }
    return NavigationActionPolicy.ALLOW;
  }

  Future<NavigationActionPolicy> externalbrowser(Uri uri) async {
    final str = uri.toString();
    appPrintC(str);
    String newStrUrl = str.replaceAll('externalbrowser://', '');
    if (newStrUrl.contains('https//')) {
      newStrUrl = newStrUrl.replaceAll('https//', 'https://');
    }
    appPrintC(newStrUrl);

    final extractUri = Uri.parse(newStrUrl);
    appPrintC(await canLaunchUrl(extractUri));

    if (await canLaunchUrl(extractUri)) {
      await launchUrl(extractUri, mode: LaunchMode.externalApplication);
    }
    return NavigationActionPolicy.CANCEL;
  }

  Future<NavigationActionPolicy> callPhone(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      final phoneNumber = uri.toString().replaceAll(RegExp(r'[^0-9]'), '');
      if (phoneNumber.contains('tel')) {
        await launchUrlString(phoneNumber);
      } else {
        await launchUrlString('tel:$phoneNumber');
      }
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }
}

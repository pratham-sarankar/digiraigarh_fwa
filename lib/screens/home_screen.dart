import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://www.digiraigarh.in'),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            allowsLinkPreview: true,
            accessibilityIgnoresInvertColors: true,
            algorithmicDarkeningAllowed: true,
            allowContentAccess: true,
            allowBackgroundAudioPlaying: true,
            allowFileAccess: true,
            allowFileAccessFromFileURLs: true,
            cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
            cacheEnabled: true,
            sharedCookiesEnabled: true,
            isPagingEnabled: true,
            allowsAirPlayForMediaPlayback: true,
            allowsBackForwardNavigationGestures: true,
            databaseEnabled: true,
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url == null) return NavigationActionPolicy.CANCEL;
            if (url.rawValue.startsWith('tel')) {
              launchUrlString(url.rawValue);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) {
            FlutterNativeSplash.remove();
          },
        ),
      ),
    );
  }
}

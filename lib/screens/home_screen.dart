import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digiraigarh_fwa/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _initialUrl = 'https://sample-files.com/documents/pdf/';
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      // If the list contains 'none', or is empty (unlikely), we are offline.
      // However, usually it contains at least one method (mobile, wifi, etc).
      // If it ONLY contains none, then we are offline.
      _isConnected = !result.contains(ConnectivityResult.none);
    });

    // If we just got reconnected and have a webview, reload it
    if (_isConnected && _webViewController != null) {
      _webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return NoInternetWidget(
        onRetry: _checkConnectivity,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(_initialUrl),
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
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onDownloadStartRequest: (controller, downloadStartRequest) async {
            await launchUrlString(
              downloadStartRequest.url.toString(),
              mode: LaunchMode.externalApplication,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url == null) return NavigationActionPolicy.CANCEL;

            // 1. Handle non-http schemes (tel, mailto, etc)
            if (!["http", "https"].contains(url.scheme)) {
              await launchUrlString(url.toString());
              return NavigationActionPolicy.CANCEL;
            }

            // 2. Compare hosts to decide if link should open in app or externally
            final initialHost = Uri.parse(_initialUrl).host;
            final domain = initialHost.replaceFirst('www.', '');

            // Use contains to allow subdomains/paths.
            if (url.host.contains(domain)) {
              return NavigationActionPolicy.ALLOW;
            }

            // External link -> Open in System Browser
            await launchUrlString(
              url.toString(),
              mode: LaunchMode.externalApplication,
            );
            return NavigationActionPolicy.CANCEL;
          },
          onLoadStop: (controller, url) {
            FlutterNativeSplash.remove();
          },
          // Handle webview errors like net::ERR_INTERNET_DISCONNECTED
          onReceivedError: (controller, request, error) {
            if (error.description.contains("net::ERR_INTERNET_DISCONNECTED")) {
              setState(() {
                _isConnected = false;
              });
            }
          },
        ),
      ),
    );
  }
}

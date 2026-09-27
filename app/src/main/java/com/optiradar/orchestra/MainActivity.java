package com.optiradar.orchestra;

import android.app.Activity;
import android.os.Bundle;
import android.os.Vibrator;
import android.content.Context;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.PermissionRequest;
import android.graphics.Color;

public class MainActivity extends Activity {
    private WebView webView;
    private Vibrator vibrator;
    private static final String SERVER_URL = "http://100.74.222.16:9090/orchestra";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().getDecorView().setBackgroundColor(Color.parseColor("#04060a"));
        vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

        webView = new WebView(this);
        setContentView(webView);
        webView.setBackgroundColor(Color.parseColor("#04060a"));

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        s.setUserAgentString(s.getUserAgentString() + " OptiRadarNative/1.0");

        // Autorisation automatique du micro natif sans blocage Chrome
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                MainActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        request.grant(request.getResources());
                        if (vibrator != null) vibrator.vibrate(40);
                    }
                });
            }
        });

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                view.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        view.loadUrl(SERVER_URL);
                    }
                }, 3000);
            }
        });

        webView.loadUrl(SERVER_URL);
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) webView.goBack();
        else super.onBackPressed();
    }
}

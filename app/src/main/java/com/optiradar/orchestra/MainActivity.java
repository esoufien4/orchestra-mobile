package com.optiradar.orchestra;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Vibrator;
import android.content.Context;
import android.content.Intent;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.RecognitionListener;
import android.speech.tts.TextToSpeech;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.PermissionRequest;
import android.webkit.JavascriptInterface;
import android.graphics.Color;
import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends Activity implements TextToSpeech.OnInitListener {
    private WebView webView;
    private Vibrator vibrator;
    private TextToSpeech tts;
    private SpeechRecognizer speechRecognizer;
    private static final String SERVER_URL = "http://100.74.222.16:9090/orchestra";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().getDecorView().setBackgroundColor(Color.parseColor("#04060a"));
        vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        tts = new TextToSpeech(this, this);

        webView = new WebView(this);
        setContentView(webView);
        webView.setBackgroundColor(Color.parseColor("#04060a"));

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        s.setUserAgentString(s.getUserAgentString() + " OptiRadarNative/2.0");

        // Liaison du pont vocal natif
        webView.addJavascriptInterface(new NativeVoiceBridge(), "AndroidBridge");

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                MainActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        request.grant(request.getResources());
                    }
                });
            }
        });

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                view.postDelayed(new Runnable() {
                    @Override
                    public void run() { view.loadUrl(SERVER_URL); }
                }, 3000);
            }
        });

        initSpeechRecognizer();
        webView.loadUrl(SERVER_URL);
    }

    private void initSpeechRecognizer() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (SpeechRecognizer.isRecognitionAvailable(MainActivity.this)) {
                    speechRecognizer = SpeechRecognizer.createSpeechRecognizer(MainActivity.this);
                    speechRecognizer.setRecognitionListener(new RecognitionListener() {
                        @Override public void onReadyForSpeech(Bundle params) {}
                        @Override public void onBeginningOfSpeech() {}
                        @Override public void onRmsChanged(float rmsdB) {}
                        @Override public void onBufferReceived(byte[] buffer) {}
                        @Override public void onEndOfSpeech() {}
                        @Override public void onError(int error) {
                            sendJs("onNativeVoiceError(" + error + ")");
                        }
                        @Override public void onResults(Bundle results) {
                            ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                            if (matches != null && !matches.isEmpty()) {
                                String text = matches.get(0).replace("'", "\\'");
                                sendJs("onNativeVoiceResult('" + text + "')");
                            }
                        }
                        @Override public void onPartialResults(Bundle partialResults) {}
                        @Override public void onEvent(int eventType, Bundle params) {}
                    });
                }
            }
        });
    }

    private void sendJs(final String script) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                webView.evaluateJavascript(script, null);
            }
        });
    }

    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            tts.setLanguage(Locale.FRENCH);
            tts.setSpeechRate(1.0f);
            tts.setPitch(0.95f);
        }
    }

    public class NativeVoiceBridge {
        @JavascriptInterface
        public void startListening() {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    if (vibrator != null) vibrator.vibrate(30);
                    Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "fr-FR");
                    if (speechRecognizer != null) speechRecognizer.startListening(intent);
                }
            });
        }

        @JavascriptInterface
        public void stopListening() {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    if (speechRecognizer != null) speechRecognizer.stopListening();
                }
            });
        }

        @JavascriptInterface
        public void speak(final String text) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    if (vibrator != null) vibrator.vibrate(20);
                    if (tts != null) {
                        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "UtteranceId");
                    }
                }
            });
        }

        @JavascriptInterface
        public void vibrate(int ms) {
            if (vibrator != null) vibrator.vibrate(ms);
        }
    }

    @Override
    protected void onDestroy() {
        if (tts != null) { tts.stop(); tts.shutdown(); }
        if (speechRecognizer != null) speechRecognizer.destroy();
        super.onDestroy();
    }
}

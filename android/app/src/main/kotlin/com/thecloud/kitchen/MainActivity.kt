package com.thecloud.kitchen

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    private val CHANNEL = "printFiscal"

override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method.equals("printFiscal")) {
                    intent = Intent()
                     intent.action = "S2S_PRINT_BON"
                     intent.putExtra("data", call.arguments as HashMap<String, Object>)
                     intent.putExtra("data_string", call.arguments.toString())
                     sendBroadcast(intent)
                } else {
                    result.notImplemented()
                }
            }
}
}

package com.example.boszhan_delivery_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        MapKitFactory.setLocale("ru")
        MapKitFactory.setApiKey("54e81d28-a461-4500-aa67-bab9da31ff13")
        super.configureFlutterEngine(flutterEngine)
    }

}

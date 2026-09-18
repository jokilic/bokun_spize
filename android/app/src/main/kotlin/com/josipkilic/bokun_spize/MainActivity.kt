package com.josipkilic.bokun_spize

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    var stepsHistoryChannel: StepsHistoryChannel? = null

    // Registers calendar-day step history queries with the Flutter engine
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        stepsHistoryChannel = StepsHistoryChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    // Releases pending history queries when the Flutter engine is detached
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        stepsHistoryChannel?.dispose()
        stepsHistoryChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

package com.test_tekit_solution

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.test_tekit_solution.Constant.ACTION.Companion.destinationLat
import com.test_tekit_solution.Constant.ACTION.Companion.destinationLong
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {


    private val CHANNEL = "com.test_tekit_solution"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startService") {
                
                var latitude: Any = call.argument("latitude")!!
                
                var longitude: Any = call.argument("longitude")!!


                Log.e(javaClass.simpleName , "latitude - "+latitude)
                Log.e(javaClass.simpleName , "longitude - "+longitude)

                 destinationLat = latitude.toString().toDouble()
                 destinationLong = longitude.toString().toDouble()
                startBackGroundService()

                result.success(1)

            } else if (call.method == "stopService") {

                stopBackGroundService()
                result.success(1)


            } else {
                result.notImplemented()
            }

        }
    }


    private fun startBackGroundService() {
        startService(Intent(applicationContext, UpdateLocationService::class.java).setAction(Constant.ACTION.STARTFOREGROUND_ACTION))
    }

    private fun stopBackGroundService() {

        stopService(Intent(applicationContext, UpdateLocationService::class.java).setAction(Constant.ACTION.STOPFOREGROUND_ACTION))
    }
}

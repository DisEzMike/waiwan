package com.waiwan.employer

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.waiwan.maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMaps" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    val label = call.argument<String>("label") ?: "Location"
                    
                    if (latitude != null && longitude != null) {
                        openGoogleMaps(latitude, longitude, label, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Latitude and longitude are required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openGoogleMaps(latitude: Double, longitude: Double, label: String, result: MethodChannel.Result) {
        try {
            // Try Google Maps app first
            val gmmIntentUri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude($label)")
            val mapIntent = Intent(Intent.ACTION_VIEW, gmmIntentUri)
            mapIntent.setPackage("com.google.android.apps.maps")
            
            if (mapIntent.resolveActivity(packageManager) != null) {
                startActivity(mapIntent)
                result.success(true)
            } else {
                // Fallback to any map app
                val genericMapIntent = Intent(Intent.ACTION_VIEW, gmmIntentUri)
                if (genericMapIntent.resolveActivity(packageManager) != null) {
                    startActivity(genericMapIntent)
                    result.success(true)
                } else {
                    // Fallback to browser
                    val browserUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude")
                    val browserIntent = Intent(Intent.ACTION_VIEW, browserUri)
                    if (browserIntent.resolveActivity(packageManager) != null) {
                        startActivity(browserIntent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
            }
        } catch (e: Exception) {
            result.error("MAPS_ERROR", "Failed to open maps: ${e.message}", null)
        }
    }
}
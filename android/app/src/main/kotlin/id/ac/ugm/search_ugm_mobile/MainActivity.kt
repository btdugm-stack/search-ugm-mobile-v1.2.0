package id.ac.ugm.search_ugm_mobile

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "id.ac.ugm.search/device"
    private val prefsName = "search_ugm_history"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openUrl" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            try {
                                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("OPEN_URL_FAILED", e.message, null)
                            }
                        }
                    }

                    "getHistory" -> {
                        val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                        val items = prefs.getStringSet("items", emptySet()) ?: emptySet()
                        // StringSet tidak menjamin urutan; simpan sebagai JSON-like list di key terpisah.
                        val stored = prefs.getString("itemsList", null)
                        val history = if (stored != null) {
                            stored.split("\u0001").filter { it.isNotEmpty() }
                        } else {
                            items.toList()
                        }
                        result.success(history)
                    }

                    "saveHistory" -> {
                        val items = call.argument<List<String>>("items") ?: emptyList()
                        val prefs = getSharedPreferences(prefsName, MODE_PRIVATE)
                        prefs.edit()
                            .putString("itemsList", items.joinToString("\u0001"))
                            .putStringSet("items", items.toSet())
                            .apply()
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}

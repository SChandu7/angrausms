package com.example.angrausmsapp2

import android.app.*
import android.content.*
import android.os.*
import android.provider.Telephony
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sms_scheduler_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "requestDefaultSms" -> {
                        val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                        intent.putExtra(
                            Telephony.Sms.Intents.EXTRA_PACKAGE_NAME,
                            packageName
                        )
                        startActivity(intent)
                        result.success(true)
                    }

                    "scheduleSms" -> {
                        val phone = call.argument<String>("phone")!!
                        val message = call.argument<String>("message")!!
                        val time = call.argument<Long>("time")!!

                        scheduleSms(phone, message, time, result)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ✅ SAFE + CORRECT
    private fun scheduleSms(
        phone: String,
        message: String,
        time: Long,
        result: MethodChannel.Result
    ) {

        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager

        // ANDROID 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {

                // Open system permission screen
                val intent = Intent(
                    android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
                )
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)

                // ❗ DO NOT schedule & DO NOT lie to Flutter
                result.error(
                    "NO_EXACT_ALARM_PERMISSION",
                    "Exact alarm permission not granted",
                    null
                )
                return
            }
        }

        // ---- PERMISSION GRANTED → SAFE TO CONTINUE ----

        val intent = Intent(this, SmsReceiver::class.java).apply {
            putExtra("phone", phone)
            putExtra("message", message)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            time.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            time,
            pendingIntent
        )

        // ✅ tell Flutter success ONLY now
        result.success(true)
    }
}

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

                    // 🔹 Request Default SMS app
                    "requestDefaultSms" -> {
                        val intent = Intent(
                            Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT
                        )
                        intent.putExtra(
                            Telephony.Sms.Intents.EXTRA_PACKAGE_NAME,
                            packageName
                        )
                        startActivity(intent)
                        result.success(true)
                    }

                    // 🔹 MULTIPLE CONTACTS + MULTIPLE TIMES
                    "scheduleMultipleSms" -> {
                        val phones =
                            ArrayList(call.argument<List<String>>("phones")!!)
                        val times =
                            ArrayList(call.argument<List<Long>>("times")!!)
                        val message =
                            call.argument<String>("message")!!

                        scheduleMultipleTimes(
                            phones,
                            message,
                            times,
                            result
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ✅ CORE SCHEDULING LOGIC
    private fun scheduleMultipleTimes(
        phones: ArrayList<String>,
        message: String,
        times: ArrayList<Long>,
        result: MethodChannel.Result
    ) {

        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager

        // 🔐 ANDROID 12+ EXACT ALARM CHECK
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {

                val intent = Intent(
                    android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
                )
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)

                result.error(
                    "NO_EXACT_ALARM_PERMISSION",
                    "Exact alarm permission not granted",
                    null
                )
                return
            }
        }

        // 🔁 CREATE ONE ALARM PER TIME
        for (time in times) {

            val intent = Intent(this, SmsReceiver::class.java).apply {
                putStringArrayListExtra("phones", phones)
                putExtra("message", message)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                this,
                time.hashCode(), // UNIQUE PER TIME
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                time,
                pendingIntent
            )
        }

        // ✅ SUCCESS ONLY AFTER ALL ALARMS SET
        result.success(true)
    }
}

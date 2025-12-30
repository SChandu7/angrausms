package com.example.angrausmsapp2

import android.content.*
import android.telephony.SmsManager

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        val phones =
            intent.getStringArrayListExtra("phones") ?: return
        val message =
            intent.getStringExtra("message") ?: return

        val smsManager = SmsManager.getDefault()

        for (phone in phones) {
            smsManager.sendTextMessage(
                phone,
                null,
                message,
                null,
                null
            )

            // ⛔ IMPORTANT: prevent SIM spam blocking
            Thread.sleep(1200)
        }
    }
}

package com.example.angrausmsapp2

import android.content.*
import android.telephony.SmsManager

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val phone = intent.getStringExtra("phone") ?: return
        val message = intent.getStringExtra("message") ?: return

        SmsManager.getDefault()
            .sendTextMessage(phone, null, message, null, null)
    }
}

package com.josipkilic.bokun_spize

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

const val REMINDERS_CHANNEL_ID = "reminders"
const val DAILY_SUMMARIES_CHANNEL_ID = "daily_summaries"
const val ANNOUNCEMENTS_CHANNEL_ID = "announcements"

class BokunSpizeApplication : Application() {
    // Creates the notification channels before Firebase can deliver a message
    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    // Registers stable channel IDs used by server-driven FCM payloads
    fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        val channels = listOf(
            NotificationChannel(
                REMINDERS_CHANNEL_ID,
                getString(R.string.notification_channel_reminders_name),
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = getString(R.string.notification_channel_reminders_description)
            },
            NotificationChannel(
                DAILY_SUMMARIES_CHANNEL_ID,
                getString(R.string.notification_channel_daily_summaries_name),
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = getString(R.string.notification_channel_daily_summaries_description)
            },
            NotificationChannel(
                ANNOUNCEMENTS_CHANNEL_ID,
                getString(R.string.notification_channel_announcements_name),
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = getString(R.string.notification_channel_announcements_description)
            },
        )

        notificationManager.createNotificationChannels(channels)
    }
}

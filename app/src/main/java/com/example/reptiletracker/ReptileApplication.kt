package com.example.reptiletracker

import android.app.Application
import com.example.reptiletracker.util.NotificationHelper
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class ReptileApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Create the system notification channel for schedule reminders
        NotificationHelper.createNotificationChannel(this)
    }
}
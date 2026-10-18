package com.example.reptiletracker.util

import android.content.Context
import android.content.Intent
import android.provider.CalendarContract
import com.example.reptiletracker.data.Pet

object CalendarUtils {
    fun addScheduleToGoogleCalendar(
        context: Context,
        pet: Pet,
        taskName: String,
        dueDateMillis: Long
    ) {
        val intent = Intent(Intent.ACTION_INSERT).apply {
            data = CalendarContract.Events.CONTENT_URI
            putExtra(CalendarContract.Events.TITLE, "${pet.name}: $taskName")
            putExtra(CalendarContract.Events.DESCRIPTION, "Reptile care task for ${pet.species}")
            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, dueDateMillis)
            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, dueDateMillis + (30 * 60 * 1000))
        }
        context.startActivity(intent)
    }
}
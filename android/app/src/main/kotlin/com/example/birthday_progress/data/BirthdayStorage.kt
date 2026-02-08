package com.example.birthday_progress.data

import android.content.Context
import android.content.SharedPreferences
import java.util.Calendar

class BirthdayStorage(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences(
        PREFS_NAME, Context.MODE_PRIVATE
    )

    fun load(): Calendar {
        val day = prefs.getLong(KEY_DAY, 1L).toInt()
        val month = prefs.getLong(KEY_MONTH, 1L).toInt()

        return Calendar.getInstance().apply {
            set(Calendar.YEAR, 2000)
            set(Calendar.MONTH, month)
            set(Calendar.DAY_OF_MONTH, day)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_DAY = "flutter.birthday_day"
        private const val KEY_MONTH = "flutter.birthday_month"
    }
}
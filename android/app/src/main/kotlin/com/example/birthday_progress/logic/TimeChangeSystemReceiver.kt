package com.example.birthday_progress.logic

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import com.example.birthday_progress.widgets.BirthdayWidgetProvider

class TimeChangeSystemReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_TIME_TICK,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            ACTION_WIDGET_UPDATE
            -> {
                updateAllWidgets(context)

                if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
                    intent.action == Intent.ACTION_MY_PACKAGE_REPLACED ||
                    intent.action == ACTION_WIDGET_UPDATE
                ) {
                    BirthdayWidgetProvider.scheduleMinutelyAlarm(context)
                }
            }
        }
    }

    private fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, BirthdayWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(component)

        if (widgetIds.isNotEmpty()) {
            widgetIds.forEach { widgetId ->
                BirthdayWidgetProvider.updateWidget(context, appWidgetManager, widgetId)
            }
        }
    }

    companion object {
        private const val ACTION_WIDGET_UPDATE =
            "com.example.birthday_progress.ACTION_WIDGET_UPDATE"
    }
}
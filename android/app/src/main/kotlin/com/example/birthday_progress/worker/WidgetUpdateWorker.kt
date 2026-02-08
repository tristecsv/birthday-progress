package com.example.birthday_progress.worker

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.example.birthday_progress.widgets.BirthdayWidgetProvider

class WidgetUpdateWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    override fun doWork(): Result {
        updateAllWidgets()
        return Result.success()
    }

    private fun updateAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)

        val birthdayComponent =
            ComponentName(applicationContext, BirthdayWidgetProvider::class.java)
        val birthdayWidgetIds = appWidgetManager.getAppWidgetIds(birthdayComponent)

        birthdayWidgetIds.forEach { widgetId ->
            BirthdayWidgetProvider.updateWidget(
                applicationContext,
                appWidgetManager,
                widgetId
            )
        }
    }
}
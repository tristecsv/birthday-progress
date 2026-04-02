package com.example.birthday_progress.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.example.birthday_progress.MainActivity
import com.example.birthday_progress.R
import com.example.birthday_progress.data.BirthdayStorage
import com.example.birthday_progress.logic.BirthdayCalculator
import com.example.birthday_progress.logic.TimeChangeSystemReceiver
import com.example.birthday_progress.worker.WidgetUpdateWorker
import java.util.Calendar
import java.util.concurrent.TimeUnit

class BirthdayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }

        scheduleMinutelyAlarm(context)
        registerSystemReceivers(context)
        schedulePeriodicWorkManager(context)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleMinutelyAlarm(context)
        registerSystemReceivers(context)
        schedulePeriodicWorkManager(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        cancelMinutelyAlarm(context)
        unregisterSystemReceivers(context)
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
    }

    companion object {
        private const val UPDATE_INTERVAL_MINUTES = 15L
        private const val WORK_NAME = "birthday_widget_update"
        private const val ACTION_WIDGET_UPDATE =
            "com.example.birthday_progress.ACTION_WIDGET_UPDATE"
        private const val ALARM_REQUEST_CODE = 1001

        private var systemReceiver: TimeChangeSystemReceiver? = null

        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SHOW_PERCENT = "flutter.birthday_showPercent"
        private const val KEY_SHOW_DAYS = "flutter.birthday_showDays"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val showPercent = prefs.getBoolean(KEY_SHOW_PERCENT, true)
            val showDays = prefs.getBoolean(KEY_SHOW_DAYS, false)

            val birthdayData = BirthdayStorage(context).load()

            val calculator = BirthdayCalculator(
                day = birthdayData.get(Calendar.DAY_OF_MONTH),
                month = birthdayData.get(Calendar.MONTH)
            )
            val progress = calculator.calculate()
            val percentage = (progress.coerceIn(0.0, 1.0) * 100).toInt()
            val days = calculator.daysUntilNextBirthday()

            val progressBitmap = BirthdayWidgetRender().render(progress)

            val isCombined = showPercent && showDays

            val views = RemoteViews(
                context.packageName,
                if (isCombined) R.layout.widget_combined else R.layout.widget_single
            )

            views.setImageViewBitmap(R.id.progress_ring, progressBitmap)

            val percentTextFormatted = context.getString(R.string.percentage_format, percentage)
            val dayTextFormatted = context.resources.getQuantityString(R.plurals.day_format, days, days)

            when {
                isCombined -> {
                    views.setTextViewText(R.id.percentage_text, percentTextFormatted)
                    views.setTextViewText(R.id.day_text, dayTextFormatted)
                }
                showPercent -> {
                    views.setViewVisibility(R.id.percentage_text, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.day_text, android.view.View.GONE)

                    views.setTextViewText(R.id.percentage_text, percentage.toString())
                }
                showDays -> {
                    views.setViewVisibility(R.id.percentage_text, android.view.View.GONE)
                    views.setViewVisibility(R.id.day_text, android.view.View.VISIBLE)

                    views.setTextViewText(R.id.day_text, dayTextFormatted)
                }
                else -> {
                    views.setViewVisibility(R.id.percentage_text, android.view.View.GONE)
                    views.setViewVisibility(R.id.day_text, android.view.View.GONE)
                }
            }

            configureClickIntent(context, views)

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun configureClickIntent(context: Context, views: RemoteViews) {
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        }

        fun scheduleMinutelyAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val intent = Intent(context, TimeChangeSystemReceiver::class.java).apply {
                action = ACTION_WIDGET_UPDATE
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            alarmManager.cancel(pendingIntent)

            val intervalMillis = 60_000L
            val triggerAtMillis = SystemClock.elapsedRealtime() + intervalMillis

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
        }

        private fun cancelMinutelyAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, TimeChangeSystemReceiver::class.java).apply {
                action = ACTION_WIDGET_UPDATE
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }

        private fun registerSystemReceivers(context: Context) {
            try {
                if (systemReceiver == null) {
                    systemReceiver = TimeChangeSystemReceiver()
                    val filter = IntentFilter().apply {
                        addAction(Intent.ACTION_TIME_TICK)
                        addAction(Intent.ACTION_TIME_CHANGED)
                        addAction(Intent.ACTION_DATE_CHANGED)
                        addAction(Intent.ACTION_TIMEZONE_CHANGED)
                    }
                    context.applicationContext.registerReceiver(systemReceiver, filter)
                }
            } catch (e: Exception) {
            }
        }

        private fun unregisterSystemReceivers(context: Context) {
            try {
                systemReceiver?.let {
                    context.applicationContext.unregisterReceiver(it)
                    systemReceiver = null
                }
            } catch (e: Exception) {
            }
        }

        fun schedulePeriodicWorkManager(context: Context) {
            val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                UPDATE_INTERVAL_MINUTES,
                TimeUnit.MINUTES
            ).build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
        }
    }
}
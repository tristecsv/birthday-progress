package com.example.birthday_progress

import android.app.AlarmManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import com.example.birthday_progress.widgets.BirthdayWidgetProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (!alarmManager.canScheduleExactAlarms()) {
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).also {
                    startActivity(it)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    METHOD_UPDATE -> {
                        updateAllWidgets()
                        result.success(null)

                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun updateAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val component = ComponentName(this, BirthdayWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(component)

        widgetIds.forEach { widgetId ->
            BirthdayWidgetProvider.updateWidget(
                this,
                appWidgetManager,
                widgetId
            )
        }
    }

    companion object {
        private const val CHANNEL_NAME = "com.example.birthday_progress/widget"
        private const val METHOD_UPDATE = "updateWidget"
    }
}

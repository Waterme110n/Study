package com.example.med_tracker_mobile

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import kotlinx.coroutines.*
import org.json.JSONArray
import java.util.*
import java.util.concurrent.TimeUnit

class MedicineWidget : AppWidgetProvider() {

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isRunning = false

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        startAutoUpdate(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        // Виджет изменил размер — обновляем
        updateAppWidget(context, appWidgetManager, appWidgetId)
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        startAutoUpdate(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        stopAutoUpdate()
    }

    private fun startAutoUpdate(context: Context) {
        if (isRunning) return
        isRunning = true
        serviceScope.launch {
            while (isActive) {
                updateAllWidgets(context)
                delay(60000)
            }
        }
    }

    private fun stopAutoUpdate() {
        isRunning = false
        serviceScope.cancel()
    }

    private fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, MedicineWidget::class.java)
        )
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val schedulesJson = prefs.getString("flutter.all_schedules", "") ?: ""

        val groupedIntakes = getTodayIntakesGrouped(schedulesJson)

        // Получаем реальную высоту виджета через размеры
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)

        // Выбираем макет в зависимости от высоты
        val layoutId = if (minHeight >= 100) {
            R.layout.medicine_widget_large
        } else {
            R.layout.medicine_widget
        }

        val views = RemoteViews(context.packageName, layoutId)

        // Обновляем заголовок в зависимости от размера
        if (layoutId == R.layout.medicine_widget_large) {
            views.setTextViewText(R.id.widget_title, "Сегодняшние приёмы")
        } else {
            views.setTextViewText(R.id.widget_title, "Приёмы")
        }

        val isLarge = layoutId == R.layout.medicine_widget_large
        val maxLines = if (isLarge) 4 else 2

        if (groupedIntakes.isEmpty()) {
            views.setViewVisibility(R.id.widget_empty, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.widget_line1, android.view.View.GONE)
            views.setViewVisibility(R.id.widget_line2, android.view.View.GONE)
            if (isLarge) {
                views.setViewVisibility(R.id.widget_line3, android.view.View.GONE)
                views.setViewVisibility(R.id.widget_line4, android.view.View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.widget_empty, android.view.View.GONE)

            views.setViewVisibility(R.id.widget_line1, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.widget_line2, android.view.View.VISIBLE)
            if (isLarge) {
                views.setViewVisibility(R.id.widget_line3, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_line4, android.view.View.VISIBLE)
            }

            // Заполняем строки
            if (groupedIntakes.size > 0) views.setTextViewText(R.id.widget_line1, groupedIntakes[0])
            if (groupedIntakes.size > 1) views.setTextViewText(R.id.widget_line2, groupedIntakes[1])

            if (isLarge) {
                if (groupedIntakes.size > 2) views.setTextViewText(R.id.widget_line3, groupedIntakes[2])
                if (groupedIntakes.size > 3) views.setTextViewText(R.id.widget_line4, groupedIntakes[3])
                if (groupedIntakes.size < 3) views.setViewVisibility(R.id.widget_line3, android.view.View.GONE)
                if (groupedIntakes.size < 4) views.setViewVisibility(R.id.widget_line4, android.view.View.GONE)
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getTodayIntakesGrouped(schedulesJson: String): List<String> {
        if (schedulesJson.isEmpty()) return emptyList()

        val now = Calendar.getInstance()
        val currentTime = now.timeInMillis
        val currentYear = now.get(Calendar.YEAR)
        val currentMonth = now.get(Calendar.MONTH)
        val currentDay = now.get(Calendar.DAY_OF_MONTH)

        val todayStart = getDayStart(currentYear, currentMonth, currentDay)
        val tomorrowStart = todayStart + TimeUnit.DAYS.toMillis(1)

        val timeToMedicines = mutableMapOf<String, MutableList<String>>()

        try {
            val schedulesArray = JSONArray(schedulesJson)

            for (i in 0 until schedulesArray.length()) {
                val schedule = schedulesArray.getJSONObject(i)
                val medicineName = schedule.getString("medicineName")
                val endDate = schedule.getLong("endDate")

                if (endDate < todayStart) continue

                val reminderTimesArray = schedule.getJSONArray("reminderTimes")

                for (j in 0 until reminderTimesArray.length()) {
                    val timeStr = reminderTimesArray.getString(j)
                    val parts = timeStr.split(":")
                    val hour = parts[0].toInt()
                    val minute = parts[1].toInt()

                    val intakeTime = getIntakeTime(currentYear, currentMonth, currentDay, hour, minute)

                    if (intakeTime >= currentTime && intakeTime < tomorrowStart) {
                        if (!timeToMedicines.containsKey(timeStr)) {
                            timeToMedicines[timeStr] = mutableListOf()
                        }
                        timeToMedicines[timeStr]!!.add(medicineName)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val sortedTimes = timeToMedicines.keys.sortedWith(compareBy { it })

        val result = mutableListOf<String>()
        for (time in sortedTimes) {
            val medicines = timeToMedicines[time]!!
            val medicinesText = if (medicines.size == 1) {
                medicines[0]
            } else {
                medicines.sorted().joinToString(", ")
            }
            result.add(" $medicinesText — $time")
        }

        return result
    }

    private fun getDayStart(year: Int, month: Int, day: Int): Long {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.YEAR, year)
            set(Calendar.MONTH, month)
            set(Calendar.DAY_OF_MONTH, day)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return calendar.timeInMillis
    }

    private fun getIntakeTime(year: Int, month: Int, day: Int, hour: Int, minute: Int): Long {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.YEAR, year)
            set(Calendar.MONTH, month)
            set(Calendar.DAY_OF_MONTH, day)
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return calendar.timeInMillis
    }
}
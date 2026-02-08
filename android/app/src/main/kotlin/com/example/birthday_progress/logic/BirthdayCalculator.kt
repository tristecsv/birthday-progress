package com.example.birthday_progress.logic

import java.util.Calendar

class BirthdayCalculator(private val day: Int, private val month: Int) {
    init {
        require(day in 1..31) { "El día debe estar entre 1 y 31" }
        require(month in 1..12) { "El mes debe estar entre 1 y 12" }
    }

    fun calculate(): Double {
        val now = Calendar.getInstance()
        val next = getNextBirthday(now)
        val last = getLastBirthday(next)

        val totalMillis = next.timeInMillis - last.timeInMillis
        val elapsedMillis = now.timeInMillis - last.timeInMillis

        if (totalMillis <= 0) return 0.0

        return (elapsedMillis.toDouble() / totalMillis.toDouble()).coerceIn(0.0, 1.0)
    }

    private fun getNextBirthday(now: Calendar): Calendar {
        val next = Calendar.getInstance().apply {
            set(Calendar.YEAR, now.get(Calendar.YEAR))
            set(Calendar.MONTH, month - 1)
            set(Calendar.DAY_OF_MONTH, day)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        if (next.before(now)) next.add(Calendar.YEAR, 1)

        return next
    }

    private fun getLastBirthday(nextBirthday: Calendar): Calendar {
        val last = nextBirthday.clone() as Calendar
        last.add(Calendar.YEAR, -1)

        return last
    }
}
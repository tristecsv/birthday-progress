package com.example.birthday_progress.logic

import java.util.Calendar

class BirthdayCalculator(private val day: Int, private val month: Int) {
    init {
        require(day in 1..31) { "El día debe estar entre 1 y 31" }
        require(month in 1..12) { "El mes debe estar entre 1 y 12" }
    }

    fun calculate(): Double {
        val now = Calendar.getInstance()

        val next = getNextBirthday()
        val last = getLastBirthday()

        val totalMillis = next.timeInMillis - last.timeInMillis
        val elapsedMillis = now.timeInMillis - last.timeInMillis

        if (totalMillis <= 0) return 0.0

        return (elapsedMillis.toDouble() / totalMillis.toDouble()).coerceIn(0.0, 1.0)
    }

    fun daysUntilNextBirthday(): Int {
        val now = Calendar.getInstance()
        now.set(Calendar.HOUR_OF_DAY, 0)
        now.set(Calendar.MINUTE, 0)
        now.set(Calendar.SECOND, 0)
        now.set(Calendar.MILLISECOND, 0)

        val next = getNextBirthday()

        val diffMillis = next.timeInMillis - now.timeInMillis

        val days = (diffMillis / (1000L * 60 * 60 * 24)).toInt()

        return maxOf(days, 0)
    }

    private fun getNextBirthday(): Calendar {
        val now = Calendar.getInstance()

        val next = now.clone() as Calendar
        next.set(Calendar.MONTH, month - 1)
        next.set(Calendar.DAY_OF_MONTH, day)
        next.set(Calendar.HOUR_OF_DAY, 0)
        next.set(Calendar.MINUTE, 0)
        next.set(Calendar.SECOND, 0)
        next.set(Calendar.MILLISECOND, 0)

        if (next.before(now)) next.add(Calendar.YEAR, 1)

        return next
    }

    private fun getLastBirthday(): Calendar {
        val last = getNextBirthday()
        last.add(Calendar.YEAR, -1)

        return last
    }
}
package com.example.birthday_progress.widgets

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import kotlin.math.min

class BirthdayWidgetRender {
    fun render(progress: Double, size: Int = DEFAULT_SIZE): Bitmap {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val center = size / 2f
        val radius = min(size / 2f, size / 2f) - (STROKE_WIDTH / 2f)

        val rect = RectF(
            center - radius,
            center - radius,
            center + radius,
            center + radius
        )

        drawTrack(canvas, rect)
        drawProgress(canvas, rect, progress)

        return bitmap
    }

    private fun drawTrack(canvas: Canvas, rect: RectF) {
        val trackPaint = Paint().apply {
            color = COLOR_TRACK
            style = Paint.Style.STROKE
            strokeWidth = STROKE_WIDTH
            strokeCap = Paint.Cap.ROUND
            isAntiAlias = true
        }

        canvas.drawArc(
            rect,
            START_ANGLE,
            TOTAL_SWEEP,
            false,
            trackPaint
        )
    }

    private fun drawProgress(canvas: Canvas, rect: RectF, progress: Double) {
        val clampedProgress = progress.coerceIn(0.0, 1.0)
        val progressSweep = TOTAL_SWEEP * clampedProgress.toFloat()

        val progressPaint = Paint().apply {
            color = COLOR_PROGRESS
            style = Paint.Style.STROKE
            strokeWidth = STROKE_WIDTH
            strokeCap = Paint.Cap.ROUND
            isAntiAlias = true
        }

        canvas.drawArc(
            rect,
            START_ANGLE,
            progressSweep,
            false,
            progressPaint
        )
    }

    companion object {
        private const val DEFAULT_SIZE = 300
        private const val STROKE_WIDTH = 40f
        private const val START_ANGLE = 150f
        private const val TOTAL_SWEEP = 240f
        private const val COLOR_TRACK = 0x4DECECEC.toInt()
        private const val COLOR_PROGRESS = 0xFF2F80ED.toInt()
    }
}
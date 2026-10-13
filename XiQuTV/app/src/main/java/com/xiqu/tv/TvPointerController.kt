package com.xiqu.tv

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.SystemClock
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.webkit.WebView
import android.widget.FrameLayout
import android.widget.Toast
import kotlin.math.max
import kotlin.math.min

/**
 * 网页焦点无法覆盖跨域播放器等控件时，提供按坐标点击的遥控器光标。
 * 光标仅在操作期间短暂显示，不会持续遮挡视频。
 */
class TvPointerController(
    private val context: Context,
    private val webView: WebView,
    private val container: FrameLayout
) {
    private val pointer = PointerView(context)
    private val hidePointer = Runnable { pointer.visibility = View.INVISIBLE }
    private var active = false
    private var x = 0f
    private var y = 0f

    init {
        val size = dp(30)
        pointer.isFocusable = false
        pointer.isClickable = false
        pointer.visibility = View.GONE
        container.addView(pointer, FrameLayout.LayoutParams(size, size))
    }

    fun handleKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode == KeyEvent.KEYCODE_MENU ||
            event.keyCode == KeyEvent.KEYCODE_INFO ||
            event.keyCode == KeyEvent.KEYCODE_GUIDE ||
            event.keyCode == KeyEvent.KEYCODE_SETTINGS
        ) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) toggle()
            return true
        }

        if (!active) return false

        if (event.keyCode == KeyEvent.KEYCODE_BACK) {
            if (event.action == KeyEvent.ACTION_DOWN) deactivate()
            return true
        }

        val supported = when (event.keyCode) {
            KeyEvent.KEYCODE_DPAD_UP,
            KeyEvent.KEYCODE_DPAD_DOWN,
            KeyEvent.KEYCODE_DPAD_LEFT,
            KeyEvent.KEYCODE_DPAD_RIGHT,
            KeyEvent.KEYCODE_DPAD_CENTER,
            KeyEvent.KEYCODE_ENTER,
            KeyEvent.KEYCODE_NUMPAD_ENTER -> true
            else -> false
        }
        if (!supported) return false
        if (event.action != KeyEvent.ACTION_DOWN) return true

        when (event.keyCode) {
            KeyEvent.KEYCODE_DPAD_UP -> move(0f, -step(event))
            KeyEvent.KEYCODE_DPAD_DOWN -> move(0f, step(event))
            KeyEvent.KEYCODE_DPAD_LEFT -> move(-step(event), 0f)
            KeyEvent.KEYCODE_DPAD_RIGHT -> move(step(event), 0f)
            else -> click()
        }
        return true
    }

    fun deactivate() {
        active = false
        pointer.removeCallbacks(hidePointer)
        pointer.visibility = View.GONE
    }

    private fun toggle() {
        if (active) {
            deactivate()
            Toast.makeText(context, "已关闭遥控器光标", Toast.LENGTH_SHORT).show()
            return
        }

        active = true
        x = webView.width / 2f
        y = webView.height / 2f
        showPointer()
        Toast.makeText(context, "光标模式：方向键移动，确认键点击，返回键退出", Toast.LENGTH_LONG).show()
    }

    private fun move(dx: Float, dy: Float) {
        val radius = pointer.width / 2f
        x = min(max(x + dx, radius), max(radius, webView.width - radius))
        y = min(max(y + dy, radius), max(radius, webView.height - radius))
        showPointer()
    }

    private fun click() {
        val now = SystemClock.uptimeMillis()
        val downEvent = MotionEvent.obtain(now, now, MotionEvent.ACTION_DOWN, x, y, 0)
        val upEvent = MotionEvent.obtain(now, now + 60, MotionEvent.ACTION_UP, x, y, 0)
        try {
            webView.dispatchTouchEvent(downEvent)
            webView.dispatchTouchEvent(upEvent)
        } finally {
            downEvent.recycle()
            upEvent.recycle()
        }

        // 点击后立即隐藏，播放开始时不在画面上留下光标；再次按方向键即可继续操作。
        pointer.removeCallbacks(hidePointer)
        pointer.visibility = View.INVISIBLE
    }

    private fun showPointer() {
        val radius = pointer.width / 2f
        pointer.x = webView.x + x - radius
        pointer.y = webView.y + y - radius
        pointer.visibility = View.VISIBLE
        pointer.bringToFront()
        pointer.removeCallbacks(hidePointer)
        pointer.postDelayed(hidePointer, POINTER_VISIBLE_MILLIS)
    }

    private fun step(event: KeyEvent): Float {
        // 轻按时使用小步长，便于对准播放器角落里的全屏、音量等小按钮；
        // 按住方向键后逐级加速，兼顾在大屏幕上的长距离移动。
        return when {
            event.repeatCount >= 10 -> dp(72).toFloat()
            event.repeatCount >= 5 -> dp(36).toFloat()
            event.repeatCount >= 2 -> dp(18).toFloat()
            else -> dp(6).toFloat()
        }
    }

    private fun dp(value: Int): Int =
        (value * context.resources.displayMetrics.density).toInt()

    private class PointerView(context: Context) : View(context) {
        private val outerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK
            style = Paint.Style.STROKE
            strokeWidth = resources.displayMetrics.density * 6
        }
        private val innerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(255, 204, 51)
            style = Paint.Style.STROKE
            strokeWidth = resources.displayMetrics.density * 3
        }
        private val centerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            style = Paint.Style.FILL
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val centerX = width / 2f
            val centerY = height / 2f
            val radius = min(width, height) / 2f - outerPaint.strokeWidth
            canvas.drawCircle(centerX, centerY, radius, outerPaint)
            canvas.drawCircle(centerX, centerY, radius, innerPaint)
            canvas.drawCircle(centerX, centerY, resources.displayMetrics.density * 2.5f, centerPaint)
        }
    }

    private companion object {
        const val POINTER_VISIBLE_MILLIS = 1800L
    }
}

package com.xiqu.tv

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class HistoryActivity : Activity() {

    private lateinit var listLayout: LinearLayout
    private lateinit var maxButton: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#1B1B2F"))
            setPadding(dp(40), dp(24), dp(40), dp(24))
        }

        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        topBar.addView(TextView(this).apply {
            text = "观看历史"
            textSize = 30f
            setTextColor(Color.parseColor("#E8B84B"))
            layoutParams = LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f)
        })

        maxButton = actionButton("上限：${HistoryManager.getMax(this)}") { cycleMax() }
        topBar.addView(maxButton)
        topBar.addView(actionButton("清空历史") { confirmClear() })

        root.addView(topBar)

        listLayout = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        root.addView(ScrollView(this).apply {
            layoutParams = LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f)
            addView(listLayout)
        })

        setContentView(root)
        refreshList()
    }

    override fun onResume() {
        super.onResume()
        refreshList()
    }

    private fun refreshList() {
        listLayout.removeAllViews()
        val items = HistoryManager.list(this)
        if (items.isEmpty()) {
            listLayout.addView(TextView(this).apply {
                text = "暂无观看记录"
                textSize = 20f
                setTextColor(Color.GRAY)
                gravity = Gravity.CENTER
                setPadding(0, dp(40), 0, 0)
            })
            return
        }
        val fmt = SimpleDateFormat("MM-dd HH:mm", Locale.getDefault())
        items.forEach { item ->
            listLayout.addView(historyRow(
                "${item.title}\n${fmt.format(Date(item.time))}  ${item.url}"
            ) { openWeb(item.title, item.url) })
        }
    }

    private fun historyRow(text: String, onClick: () -> Unit): View {
        val bg = GradientDrawable().apply {
            setColor(Color.parseColor("#2D2D44"))
            cornerRadius = dp(8).toFloat()
        }
        val bgFocused = GradientDrawable().apply {
            setColor(Color.parseColor("#C84B31"))
            cornerRadius = dp(8).toFloat()
        }
        return TextView(this).apply {
            this.text = text
            textSize = 18f
            setTextColor(Color.WHITE)
            setPadding(dp(20), dp(12), dp(20), dp(12))
            background = bg
            isFocusable = true
            isFocusableInTouchMode = true
            layoutParams = LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT).apply {
                topMargin = dp(10)
            }
            setOnFocusChangeListener { v, hasFocus ->
                v.background = if (hasFocus) bgFocused else bg
            }
            setOnClickListener { onClick() }
        }
    }

    private fun actionButton(text: String, onClick: () -> Unit): TextView {
        val bg = GradientDrawable().apply {
            setColor(Color.parseColor("#2D2D44"))
            cornerRadius = dp(8).toFloat()
        }
        val bgFocused = GradientDrawable().apply {
            setColor(Color.parseColor("#C84B31"))
            cornerRadius = dp(8).toFloat()
        }
        return TextView(this).apply {
            this.text = text
            textSize = 18f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            background = bg
            isFocusable = true
            isFocusableInTouchMode = true
            setPadding(dp(18), dp(10), dp(18), dp(10))
            layoutParams = LinearLayout.LayoutParams(WRAP_CONTENT, WRAP_CONTENT).apply {
                marginStart = dp(16)
            }
            setOnFocusChangeListener { v, hasFocus ->
                v.background = if (hasFocus) bgFocused else bg
            }
            setOnClickListener { onClick() }
        }
    }

    private fun cycleMax() {
        val options = HistoryManager.MAX_OPTIONS
        val cur = HistoryManager.getMax(this)
        val next = options[(options.indexOf(cur) + 1) % options.size]
        HistoryManager.setMax(this, next)
        maxButton.text = "上限：$next"
        refreshList()
    }

    private fun confirmClear() {
        AlertDialog.Builder(this)
            .setTitle("清空历史")
            .setMessage("确定删除全部观看记录？")
            .setPositiveButton("清空") { _, _ ->
                HistoryManager.clear(this)
                refreshList()
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun openWeb(title: String, url: String) {
        startActivity(Intent(this, WebViewActivity::class.java).apply {
            putExtra(WebViewActivity.EXTRA_TITLE, title)
            putExtra(WebViewActivity.EXTRA_URL, url)
        })
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density).toInt()
}

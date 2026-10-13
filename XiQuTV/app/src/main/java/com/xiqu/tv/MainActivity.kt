package com.xiqu.tv

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {

    private val sites = listOf(
        "CCTV空中剧院" to "https://tv.cctv.com/lm/cctvkzjy/",
        "中国戏曲像音像集萃" to "https://tv.cctv.com/lm/zgjjxyxjc/videoset",
        "央视网戏曲频道" to "https://xiqu.cctv.com/xqys/index.shtml",
        "看戏网" to "https://search.bilibili.com/all"
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setBackgroundColor(Color.parseColor("#1B1B2F"))
            setPadding(dp(60), dp(40), dp(60), dp(40))
        }

        root.addView(TextView(this).apply {
            text = "戏曲TV"
            textSize = 36f
            setTextColor(Color.parseColor("#E8B84B"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(30))
        })

        sites.forEach { (name, url) ->
            root.addView(menuButton(name) { openWeb(name, url) })
        }

        root.addView(menuButton("自定义网址") { showUrlDialog() })
        root.addView(menuButton("观看历史") {
            startActivity(Intent(this, HistoryActivity::class.java))
        })

        setContentView(root)
        root.getChildAt(1)?.requestFocus()
    }

    private fun menuButton(text: String, onClick: () -> Unit): View {
        val bg = GradientDrawable().apply {
            setColor(Color.parseColor("#2D2D44"))
            cornerRadius = dp(10).toFloat()
        }
        val bgFocused = GradientDrawable().apply {
            setColor(Color.parseColor("#C84B31"))
            cornerRadius = dp(10).toFloat()
        }
        return TextView(this).apply {
            this.text = text
            textSize = 24f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            background = bg
            isFocusable = true
            isFocusableInTouchMode = true
            layoutParams = LinearLayout.LayoutParams(dp(520), dp(72)).apply {
                topMargin = dp(14)
            }
            setOnFocusChangeListener { v, hasFocus ->
                v.background = if (hasFocus) bgFocused else bg
                v.scaleX = if (hasFocus) 1.05f else 1f
                v.scaleY = if (hasFocus) 1.05f else 1f
            }
            setOnClickListener { onClick() }
        }
    }

    private fun showUrlDialog() {
        val input = EditText(this).apply {
            hint = "输入网址，如 https://example.com"
            setSingleLine()
        }
        AlertDialog.Builder(this)
            .setTitle("自定义网址")
            .setView(input)
            .setPositiveButton("打开") { _, _ ->
                var url = input.text.toString().trim()
                if (url.isNotEmpty()) {
                    if (!url.startsWith("http")) url = "https://$url"
                    openWeb(url, url)
                } else {
                    Toast.makeText(this, "网址不能为空", Toast.LENGTH_SHORT).show()
                }
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

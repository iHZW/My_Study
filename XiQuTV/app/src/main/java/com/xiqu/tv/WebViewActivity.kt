package com.xiqu.tv

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.Toast

class WebViewActivity : Activity() {

    companion object {
        const val EXTRA_TITLE = "title"
        const val EXTRA_URL = "url"
    }

    private lateinit var webView: WebView
    private lateinit var container: FrameLayout
    private lateinit var pointerController: TvPointerController
    private val tvWebNavigator = TvWebNavigator()
    private var customView: View? = null
    private var customCallback: WebChromeClient.CustomViewCallback? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val url = intent.getStringExtra(EXTRA_URL) ?: run {
            finish(); return
        }

        container = FrameLayout(this).apply { setBackgroundColor(Color.BLACK) }
        val progress = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            max = 100
            layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, 12)
        }

        webView = WebView(this).apply {
            layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
            isFocusable = true
            isFocusableInTouchMode = true
            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                mediaPlaybackRequiresUserGesture = false
                loadWithOverviewMode = true
                useWideViewPort = true
                builtInZoomControls = true
                displayZoomControls = false
                mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
                userAgentString = "$userAgentString XiQuTV"
            }
            webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, pageUrl: String) {
                    tvWebNavigator.install(view)
                    val title = view.title
                    if (!title.isNullOrBlank() && pageUrl.startsWith("http")) {
                        HistoryManager.add(this@WebViewActivity, title, pageUrl)
                    }
                }

                override fun onReceivedError(
                    view: WebView, errorCode: Int, description: String?, failingUrl: String?
                ) {
                    if (failingUrl == url) {
                        Toast.makeText(
                            this@WebViewActivity,
                            "加载失败：$description",
                            Toast.LENGTH_LONG
                        ).show()
                    }
                }
            }
            webChromeClient = object : WebChromeClient() {
                override fun onProgressChanged(view: WebView, newProgress: Int) {
                    progress.progress = newProgress
                    progress.visibility = if (newProgress >= 100) View.GONE else View.VISIBLE
                }

                override fun onShowCustomView(view: View, callback: CustomViewCallback) {
                    pointerController.deactivate()
                    customView = view
                    customCallback = callback
                    container.addView(
                        view,
                        FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
                    )
                    webView.visibility = View.GONE
                }

                override fun onHideCustomView() {
                    customView?.let { container.removeView(it) }
                    customView = null
                    customCallback?.onCustomViewHidden()
                    customCallback = null
                    webView.visibility = View.VISIBLE
                }
            }
            loadUrl(url)
        }

        container.addView(webView)
        container.addView(progress)
        pointerController = TvPointerController(this, webView, container)
        setContentView(container)
        webView.requestFocus()
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (customView == null && ::pointerController.isInitialized &&
            pointerController.handleKeyEvent(event)
        ) {
            return true
        }
        // 普通网页使用空间导航；全屏时由播放器自己的控件处理遥控器按键。
        if (customView == null && ::webView.isInitialized &&
            tvWebNavigator.handleKeyEvent(webView, event)
        ) {
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onBackPressed() {
        when {
            customView != null -> {
                customCallback?.onCustomViewHidden()
                customView?.let { container.removeView(it) }
                customView = null
                customCallback = null
                webView.visibility = View.VISIBLE
            }
            webView.canGoBack() -> webView.goBack()
            else -> super.onBackPressed()
        }
    }

    override fun onPause() {
        if (::pointerController.isInitialized) pointerController.deactivate()
        super.onPause()
        webView.onPause()
    }

    override fun onResume() {
        super.onResume()
        webView.onResume()
    }

    override fun onDestroy() {
        (webView.parent as? ViewGroup)?.removeView(webView)
        webView.destroy()
        super.onDestroy()
    }
}

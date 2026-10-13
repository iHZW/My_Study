package com.xiqu.tv

import android.view.KeyEvent
import android.webkit.WebView

/**
 * 为按鼠标操作设计的网页补充电视遥控器空间导航能力。
 *
 * 网页每次按键时都会重新收集可见控件，因此也能识别异步加载出来的视频列表和播放器按钮。
 */
class TvWebNavigator {

    fun install(webView: WebView) {
        webView.evaluateJavascript(INSTALL_SCRIPT, null)
    }

    fun handleKeyEvent(webView: WebView, event: KeyEvent): Boolean {
        val action = when (event.keyCode) {
            KeyEvent.KEYCODE_DPAD_UP -> "move" to "up"
            KeyEvent.KEYCODE_DPAD_DOWN -> "move" to "down"
            KeyEvent.KEYCODE_DPAD_LEFT -> "move" to "left"
            KeyEvent.KEYCODE_DPAD_RIGHT -> "move" to "right"
            KeyEvent.KEYCODE_DPAD_CENTER,
            KeyEvent.KEYCODE_ENTER,
            KeyEvent.KEYCODE_NUMPAD_ENTER -> "activate" to null
            KeyEvent.KEYCODE_MEDIA_PLAY,
            KeyEvent.KEYCODE_MEDIA_PAUSE,
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE -> "togglePlayback" to null
            else -> return false
        }

        // 同时消费按下和抬起事件，避免 WebView 收到没有对应按下动作的抬起事件。
        if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
            runCommand(webView, action.first, action.second)
        }
        return true
    }

    private fun runCommand(webView: WebView, command: String, argument: String? = null) {
        val invocation = if (argument == null) {
            "window.XiQuTvNavigation && window.XiQuTvNavigation.$command();"
        } else {
            "window.XiQuTvNavigation && window.XiQuTvNavigation.$command('$argument');"
        }
        webView.evaluateJavascript(invocation, null)
    }

    private companion object {
        val INSTALL_SCRIPT = """
            (function () {
              if (window.XiQuTvNavigation) {
                window.XiQuTvNavigation.refresh();
                return;
              }

              var current = null;
              var styleId = 'xiqu-tv-navigation-style';
              var selectedClass = 'xiqu-tv-selected';
              var selector = [
                'a[href]', 'button', 'input:not([type="hidden"])', 'select', 'textarea',
                '[role="button"]', '[role="link"]', '[role="menuitem"]', '[role="option"]',
                '[tabindex]:not([tabindex="-1"])', '[onclick]', '[aria-label]',
                'video', 'iframe'
              ].join(',');

              function addStyle() {
                if (document.getElementById(styleId)) return;
                var style = document.createElement('style');
                style.id = styleId;
                style.textContent =
                  '.' + selectedClass + ' {' +
                  'outline: 5px solid #ffcc33 !important;' +
                  'outline-offset: 4px !important;' +
                  'box-shadow: 0 0 0 4px rgba(0,0,0,.75), 0 0 22px 8px rgba(255,204,51,.9) !important;' +
                  'transition: outline-color .12s, box-shadow .12s;' +
                  'z-index: 2147483646 !important;' +
                  '}';
                (document.head || document.documentElement).appendChild(style);
              }

              function visible(element) {
                if (!element || !element.isConnected || element.disabled) return false;
                var style = window.getComputedStyle(element);
                if (style.display === 'none' || style.visibility === 'hidden' ||
                    parseFloat(style.opacity || '1') < 0.05) return false;
                var rect = element.getBoundingClientRect();
                return rect.width >= 8 && rect.height >= 8 &&
                  rect.bottom >= 0 && rect.right >= 0 &&
                  rect.top <= window.innerHeight && rect.left <= window.innerWidth;
              }

              function candidates() {
                return Array.prototype.filter.call(document.querySelectorAll(selector), visible);
              }

              function center(rect) {
                return { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
              }

              function select(element) {
                if (!element) return false;
                if (current && current !== element) current.classList.remove(selectedClass);
                current = element;
                current.classList.add(selectedClass);
                try {
                  current.focus({ preventScroll: true });
                } catch (ignore) {
                  try { current.focus(); } catch (ignored) {}
                }
                current.scrollIntoView({ block: 'center', inline: 'center', behavior: 'smooth' });
                scheduleHighlightRemoval();
                return true;
              }

              var highlightTimer = null;
              function scheduleHighlightRemoval(delay) {
                if (highlightTimer) window.clearTimeout(highlightTimer);
                highlightTimer = window.setTimeout(function () {
                  if (current) current.classList.remove(selectedClass);
                }, delay || 2200);
              }

              function clearHighlight() {
                if (highlightTimer) window.clearTimeout(highlightTimer);
                if (current) current.classList.remove(selectedClass);
              }

              function firstCandidate(items) {
                var viewportCenter = { x: window.innerWidth / 2, y: window.innerHeight / 2 };
                var best = null;
                var bestScore = Number.MAX_VALUE;
                items.forEach(function (element) {
                  var point = center(element.getBoundingClientRect());
                  var score = Math.abs(point.x - viewportCenter.x) + Math.abs(point.y - viewportCenter.y);
                  if (score < bestScore) {
                    best = element;
                    bestScore = score;
                  }
                });
                return best;
              }

              function move(direction) {
                addStyle();
                var items = candidates();
                if (!items.length) {
                  window.scrollBy({
                    top: direction === 'down' ? window.innerHeight * 0.7 :
                         direction === 'up' ? -window.innerHeight * 0.7 : 0,
                    left: direction === 'right' ? window.innerWidth * 0.7 :
                          direction === 'left' ? -window.innerWidth * 0.7 : 0,
                    behavior: 'smooth'
                  });
                  return false;
                }

                if (!visible(current)) return select(firstCandidate(items));

                var origin = center(current.getBoundingClientRect());
                var best = null;
                var bestScore = Number.MAX_VALUE;
                items.forEach(function (element) {
                  if (element === current) return;
                  var point = center(element.getBoundingClientRect());
                  var dx = point.x - origin.x;
                  var dy = point.y - origin.y;
                  var primary;
                  var secondary;

                  if (direction === 'left' && dx < -2) { primary = -dx; secondary = Math.abs(dy); }
                  else if (direction === 'right' && dx > 2) { primary = dx; secondary = Math.abs(dy); }
                  else if (direction === 'up' && dy < -2) { primary = -dy; secondary = Math.abs(dx); }
                  else if (direction === 'down' && dy > 2) { primary = dy; secondary = Math.abs(dx); }
                  else return;

                  var score = primary + secondary * 2.5 + (secondary > primary * 2 ? 10000 : 0);
                  if (score < bestScore) {
                    best = element;
                    bestScore = score;
                  }
                });

                if (best) return select(best);

                window.scrollBy({
                  top: direction === 'down' ? window.innerHeight * 0.65 :
                       direction === 'up' ? -window.innerHeight * 0.65 : 0,
                  left: direction === 'right' ? window.innerWidth * 0.65 :
                        direction === 'left' ? -window.innerWidth * 0.65 : 0,
                  behavior: 'smooth'
                });
                return false;
              }

              function activate() {
                if (!visible(current)) {
                  var items = candidates();
                  if (!items.length) return false;
                  select(firstCandidate(items));
                  return true;
                }

                if (current.tagName === 'VIDEO') {
                  if (current.paused) current.play(); else current.pause();
                  clearHighlight();
                  return true;
                }

                current.click();
                scheduleHighlightRemoval(450);
                return true;
              }

              function togglePlayback() {
                var videos = Array.prototype.filter.call(document.querySelectorAll('video'), visible);
                if (!videos.length) return false;
                videos.sort(function (a, b) {
                  var ar = a.getBoundingClientRect();
                  var br = b.getBoundingClientRect();
                  return br.width * br.height - ar.width * ar.height;
                });
                var video = videos[0];
                if (video.paused) video.play(); else video.pause();
                current = video;
                clearHighlight();
                return true;
              }

              document.addEventListener('focusin', function (event) {
                if (event.target && event.target.matches && event.target.matches(selector)) {
                  select(event.target);
                }
              }, true);

              document.addEventListener('click', function (event) {
                var target = event.target && event.target.closest ? event.target.closest(selector) : null;
                if (target) select(target);
              }, true);

              window.XiQuTvNavigation = {
                move: move,
                activate: activate,
                togglePlayback: togglePlayback,
                clearHighlight: clearHighlight,
                refresh: addStyle
              };
              addStyle();
            })();
        """.trimIndent()
    }
}

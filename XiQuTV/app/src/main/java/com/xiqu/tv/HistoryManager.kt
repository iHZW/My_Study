package com.xiqu.tv

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object HistoryManager {

    data class Item(val title: String, val url: String, val time: Long)

    private const val PREFS = "xiqu_prefs"
    private const val KEY_ITEMS = "history_items"
    private const val KEY_MAX = "history_max"
    const val DEFAULT_MAX = 100
    val MAX_OPTIONS = listOf(50, 100, 200, 500)

    fun getMax(context: Context): Int =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getInt(KEY_MAX, DEFAULT_MAX)

    fun setMax(context: Context, max: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putInt(KEY_MAX, max).apply()
        trim(context)
    }

    fun add(context: Context, title: String, url: String) {
        val list = list(context).toMutableList()
        list.removeAll { it.url == url }
        list.add(0, Item(title.ifBlank { url }, url, System.currentTimeMillis()))
        save(context, list)
        trim(context)
    }

    fun list(context: Context): List<Item> {
        val json = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_ITEMS, "[]") ?: "[]"
        val result = mutableListOf<Item>()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                result.add(Item(o.optString("t"), o.optString("u"), o.optLong("time")))
            }
        } catch (_: Exception) {
        }
        return result
    }

    fun clear(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(KEY_ITEMS, "[]").apply()
    }

    private fun trim(context: Context) {
        val max = getMax(context)
        val list = list(context)
        if (list.size > max) save(context, list.take(max))
    }

    private fun save(context: Context, list: List<Item>) {
        val arr = JSONArray()
        list.forEach {
            arr.put(JSONObject().put("t", it.title).put("u", it.url).put("time", it.time))
        }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(KEY_ITEMS, arr.toString()).apply()
    }
}

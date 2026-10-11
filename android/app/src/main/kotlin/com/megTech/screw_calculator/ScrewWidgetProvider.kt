package com.megTech.screw_calculator

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** ويدجت الشاشة الرئيسية: ملخّص آخر لعبة (الفائز والخاسر). */
class ScrewWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val winner = widgetData.getString("last_winner", null)
        val winnerTotal = widgetData.getString("last_winner_total", "")
        val loser = widgetData.getString("last_loser", "")
        val loserTotal = widgetData.getString("last_loser_total", "")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.screw_widget)

            if (winner.isNullOrEmpty()) {
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setViewVisibility(R.id.widget_content, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setViewVisibility(R.id.widget_content, View.VISIBLE)
                views.setTextViewText(
                    R.id.widget_winner,
                    context.getString(R.string.widget_winner, winner, winnerTotal),
                )
                views.setTextViewText(
                    R.id.widget_loser,
                    context.getString(R.string.widget_loser, loser, loserTotal),
                )
            }

            // الضغط على الويدجت يفتح التطبيق.
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                val pending = PendingIntent.getActivity(
                    context,
                    0,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

package com.example.rehabit

import android.net.Uri
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.graphics.PixelFormat
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.app.usage.UsageEvents
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screen_time_channel"
    private var overlayView: View? = null
    private var windowManager: WindowManager? = null

    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "getAppUsageStats" -> {
                    val stats = getAppUsageStats()
                    result.success(stats)
                }
                "getTotalScreenTime" -> {
                    val totalTime = getTotalScreenTime()
                    result.success(totalTime)
                }
                "getAppScreenTime" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val minutes = getAppScreenTime(packageName)
                    result.success(minutes)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }

                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }

                "showOverlay" -> {
                    val message = call.argument<String>("message") ?: "Time’s up!"
                    showOverlay(message)
                    result.success(true)
                }

                "removeOverlay" -> {
                    removeOverlay()
                    result.success(true)
                }
                
                "startForegroundService" -> {
                    val serviceIntent = Intent(this, ForegroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopForegroundService" -> {
                    val serviceIntent = Intent(this, ForegroundService::class.java)
                    stopService(serviceIntent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

    }
        
    private fun hasUsageStatsPermission(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)

        // Return true if at least one event is available
        return usageEvents.hasNextEvent()
    }

    
    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }
    
    private fun getAppUsageStats(): List<Map<String, Any?>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        // Start from today's midnight
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)

        // Map to hold intervals per package: package -> list of (start, end)
        val appIntervals = mutableMapOf<String, MutableList<Pair<Long, Long>>>()
        // Current foreground start time per app
        val currentForegroundStart = mutableMapOf<String, Long>()

        val foregroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_FOREGROUND,
            UsageEvents.Event.ACTIVITY_RESUMED
        )
        val backgroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_BACKGROUND,
            UsageEvents.Event.ACTIVITY_PAUSED
        )

        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            val pkg = event.packageName
            val ts = event.timeStamp

            if (event.eventType in foregroundEvents) {
                // Start timing for this package if not already started
                if (currentForegroundStart[pkg] == null) {
                    currentForegroundStart[pkg] = ts
                }
            } else if (event.eventType in backgroundEvents) {
                // Stop timing for this package if timing started
                val start = currentForegroundStart[pkg]
                if (start != null) {
                    // Add interval to appIntervals
                    val intervals = appIntervals.getOrPut(pkg) { mutableListOf() }
                    intervals.add(Pair(start, ts))
                    currentForegroundStart.remove(pkg)
                }
            }
        }

        // Close any intervals still running till endTime
        currentForegroundStart.forEach { (pkg, start) ->
            val intervals = appIntervals.getOrPut(pkg) { mutableListOf() }
            intervals.add(Pair(start, endTime))
        }

        // Calculate total time per app by merging overlapping intervals for each app
        fun mergeIntervals(intervals: List<Pair<Long, Long>>): List<Pair<Long, Long>> {
            if (intervals.isEmpty()) return emptyList()
            val sorted = intervals.sortedBy { it.first }
            val merged = mutableListOf(sorted[0])

            for (i in 1 until sorted.size) {
                val last = merged.last()
                val current = sorted[i]
                if (current.first <= last.second) {
                    // Overlapping intervals, merge them
                    merged[merged.size - 1] = Pair(last.first, maxOf(last.second, current.second))
                } else {
                    merged.add(current)
                }
            }
            return merged
        }

        val result = mutableListOf<Map<String, Any?>>()

        for ((pkg, intervals) in appIntervals) {
            // Filter out system apps
            if (pkg.startsWith("com.android.") ||
                pkg.startsWith("android.") ||
                pkg == "android" ||
                pkg.contains("launcher") ||
                pkg.contains("systemui") ||
                pkg == packageName) {
                continue
            }

            val merged = mergeIntervals(intervals)
            val totalTime = merged.sumOf { it.second - it.first }

            // Filter for meaningful usage > 30 seconds
            if (totalTime > 30000) {
                val lastTimeUsed = merged.maxOfOrNull { it.second } ?: 0L
                result.add(
                    mapOf(
                        "packageName" to pkg,
                        "totalTimeInForeground" to totalTime,
                        "lastTimeUsed" to lastTimeUsed
                    )
                )
            }
        }

        return result.sortedByDescending { it["totalTimeInForeground"] as Long }
            .take(20)
    }

    
    private fun getTotalScreenTime(): Long {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        // Start of today midnight
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)

        val intervals = mutableListOf<Pair<Long, Long>>() // List of foreground intervals (start, end)

        var currentForegroundStart: Long? = null
        var currentForegroundApp: String? = null

        val foregroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_FOREGROUND,
            UsageEvents.Event.ACTIVITY_RESUMED
        )
        val backgroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_BACKGROUND,
            UsageEvents.Event.ACTIVITY_PAUSED
        )

        var lastTimestamp = startTime

        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)

            if (event.eventType in foregroundEvents) {
                // App moved to foreground, start timing
                if (currentForegroundStart == null) {
                    currentForegroundStart = event.timeStamp
                    currentForegroundApp = event.packageName
                }
            } else if (event.eventType in backgroundEvents) {
                // App moved to background, close timing interval if matching app
                if (currentForegroundStart != null && currentForegroundApp == event.packageName) {
                    intervals.add(Pair(currentForegroundStart, event.timeStamp))
                    currentForegroundStart = null
                    currentForegroundApp = null
                }
            }

            lastTimestamp = event.timeStamp
        }

        // If still foreground after last event, close interval at endTime
        if (currentForegroundStart != null) {
            intervals.add(Pair(currentForegroundStart, endTime))
        }

        // Merge overlapping intervals
        intervals.sortBy { it.first }

        val mergedIntervals = mutableListOf<Pair<Long, Long>>()
        for (interval in intervals) {
            if (mergedIntervals.isEmpty()) {
                mergedIntervals.add(interval)
            } else {
                val last = mergedIntervals.last()
                if (interval.first <= last.second) {
                    // Overlapping, merge
                    mergedIntervals[mergedIntervals.size - 1] = Pair(last.first, maxOf(last.second, interval.second))
                } else {
                    mergedIntervals.add(interval)
                }
            }
        }

        // Sum durations
        var totalScreenTimeMs: Long = 0
        for (interval in mergedIntervals) {
            totalScreenTimeMs += (interval.second - interval.first)
        }

        return totalScreenTimeMs
    }


    private fun getAppScreenTime(packageName: String): Int {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)

        val foregroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_FOREGROUND,
            UsageEvents.Event.ACTIVITY_RESUMED
        )
        val backgroundEvents = setOf(
            UsageEvents.Event.MOVE_TO_BACKGROUND,
            UsageEvents.Event.ACTIVITY_PAUSED
        )

        val intervals = mutableListOf<Pair<Long, Long>>()
        var currentStart: Long? = null

        val event = UsageEvents.Event()
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            if (event.packageName != packageName) continue

            if (event.eventType in foregroundEvents) {
                if (currentStart == null) {
                    currentStart = event.timeStamp
                }
            } else if (event.eventType in backgroundEvents) {
                if (currentStart != null) {
                    intervals.add(Pair(currentStart, event.timeStamp))
                    currentStart = null
                }
            }
        }

        // If app still foreground at end, close interval at current time
        if (currentStart != null) {
            intervals.add(Pair(currentStart, endTime))
        }

        // Merge overlapping intervals (usually not needed for single app, but good practice)
        val mergedIntervals = mutableListOf<Pair<Long, Long>>()
        intervals.sortedBy { it.first }.forEach { interval ->
            if (mergedIntervals.isEmpty()) {
                mergedIntervals.add(interval)
            } else {
                val last = mergedIntervals.last()
                if (interval.first <= last.second) {
                    mergedIntervals[mergedIntervals.size - 1] = Pair(last.first, maxOf(last.second, interval.second))
                } else {
                    mergedIntervals.add(interval)
                }
            }
        }

        val totalMs = mergedIntervals.sumOf { it.second - it.first }
        return (totalMs / 60000).toInt()  // convert ms to minutes
    }

    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                startActivityForResult(intent, 1234)
            }
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true // Overlay permission automatically granted on older Android versions
        }
    }
    
    private fun showOverlay(message: String = "Time’s up!") {
        if (overlayView != null) return // Already showing

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

        // Simple overlay layout
        overlayView = TextView(this).apply {
            text = message
            textSize = 22f
            setBackgroundColor(0xAA000000.toInt()) // semi-transparent black
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(50, 50, 50, 50)
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                    or WindowManager.LayoutParams.FLAG_FULLSCREEN,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.CENTER
        windowManager?.addView(overlayView, params)
    }

    private fun removeOverlay() {
        overlayView?.let {
            windowManager?.removeView(it)
            overlayView = null
        }
    }

}
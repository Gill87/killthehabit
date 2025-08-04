package com.example.rehabit

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screen_time_channel"
    
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
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun hasUsageStatsPermission(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        return usageStats.isNotEmpty()
    }
    
    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }
    
    private fun getAppUsageStats(): List<Map<String, Any?>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1) // Last 24 hours
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        // Debug: Print all usage stats to see what we're getting
        println("Total usage stats found: ${usageStats.size}")
        for (stat in usageStats) {
            println("Package: ${stat.packageName}, Time: ${stat.totalTimeInForeground}ms")
        }
        
        // Filter for meaningful app usage (more than 30 seconds of foreground time)
        return usageStats.filter { 
            it.totalTimeInForeground > 30000 && // More than 30 seconds
            !it.packageName.startsWith("com.android.") && // Filter system apps
            !it.packageName.startsWith("android.") &&
            it.packageName != "android" && // Filter the "android" system package
            !it.packageName.contains("launcher") && // Filter launchers
            !it.packageName.contains("systemui") && // Filter system UI
            it.packageName != packageName // Don't include our own app
        }.map { stat ->
            hashMapOf<String, Any?>(
                "packageName" to stat.packageName,
                "totalTimeInForeground" to stat.totalTimeInForeground, // Active usage time only
                "lastTimeUsed" to stat.lastTimeUsed
            )
        }.sortedByDescending { (it["totalTimeInForeground"] as Long) }
            .take(20) // Limit to top 20 apps
    }
    
    private fun getTotalScreenTime(): Long {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1) // Last 24 hours
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        
        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        // Debug: Print total stats found
        println("Getting total screen time. Stats found: ${usageStats.size}")
        
        // Calculate total screen time across all apps
        var totalTime: Long = 0
        for (usageStat in usageStats) {
            // Only count meaningful usage (more than 30 seconds)
            if (usageStat.totalTimeInForeground > 30000) {
                totalTime += usageStat.totalTimeInForeground
                println("Adding ${usageStat.packageName}: ${usageStat.totalTimeInForeground}ms")
            }
        }
        
        println("Total calculated time: ${totalTime}ms")
        return totalTime
    }
}
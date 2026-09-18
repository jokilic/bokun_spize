package com.josipkilic.bokun_spize

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateGroupByPeriodRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.time.LocalDateTime
import java.time.Period
import java.time.ZoneId
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

// Exposes the available history boundary and native daily aggregation to Flutter
class StepsHistoryChannel(val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    val channel = MethodChannel(messenger, "com.josipkilic.bokun_spize/steps_history")
    val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    // Registers the handler without creating a Health Connect client before availability is checked
    init {
        channel.setMethodCallHandler(this)
    }

    // Dispatches queries and reports failures without turning them into zero steps
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getEarliestStepDate" && call.method != "getDailySteps") {
            result.notImplemented()
            return
        }

        val endTime = call.argument<Number>("endTime")?.toLong()
        val startTime = call.argument<Number>("startTime")?.toLong()
        if (endTime == null || (call.method == "getDailySteps" && (startTime == null || startTime >= endTime))) {
            result.error("INVALID_INTERVAL", "A valid step history interval is required", null)
            return
        }

        scope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(context)
                when (call.method) {
                    "getEarliestStepDate" -> result.success(getEarliestStepDate(client, Instant.ofEpochMilli(endTime)))
                    "getDailySteps" -> result.success(
                        getDailySteps(client, Instant.ofEpochMilli(startTime!!), Instant.ofEpochMilli(endTime))
                    )
                }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                result.error("STEPS_HISTORY_ERROR", error.message, null)
            }
        }
    }

    // Lets Health Connect restrict the query to records allowed by the current permissions
    suspend fun getEarliestStepDate(client: HealthConnectClient, endTime: Instant): Long? {
        var pageToken: String? = null
        do {
            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = StepsRecord::class,
                    timeRangeFilter = TimeRangeFilter.before(endTime),
                    ascendingOrder = true,
                    pageSize = 1,
                    pageToken = pageToken,
                )
            )
            response.records.firstOrNull()?.let { return it.startTime.toEpochMilli() }
            pageToken = response.pageToken
        } while (!pageToken.isNullOrEmpty())

        return null
    }

    // Uses calendar days and Health Connect aggregation to handle DST and overlapping sources
    suspend fun getDailySteps(client: HealthConnectClient, startTime: Instant, endTime: Instant): List<Map<String, Long>> {
        val zone = ZoneId.systemDefault()
        val response = client.aggregateGroupByPeriod(
            AggregateGroupByPeriodRequest(
                metrics = setOf(StepsRecord.COUNT_TOTAL),
                timeRangeFilter = TimeRangeFilter.between(
                    LocalDateTime.ofInstant(startTime, zone),
                    LocalDateTime.ofInstant(endTime, zone),
                ),
                timeRangeSlicer = Period.ofDays(1),
            )
        )

        return response.map { bucket ->
            mapOf(
                "date" to bucket.startTime.atZone(zone).toInstant().toEpochMilli(),
                "steps" to (bucket.result[StepsRecord.COUNT_TOTAL] ?: 0L),
            )
        }
    }

    // Stops work and removes the channel handler when the engine is detached
    fun dispose() {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}

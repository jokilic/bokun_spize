import Flutter
import HealthKit

class StepsHistoryPlugin: NSObject, FlutterPlugin {
  let healthStore = HKHealthStore()

  // Registers history queries alongside the Flutter health plugin
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.josipkilic.bokun_spize/steps_history",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(StepsHistoryPlugin(), channel: channel)
  }

  // Validates requests before querying the health store
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getEarliestStepDate" || call.method == "getDailySteps" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard HKHealthStore.isHealthDataAvailable() else {
      result(FlutterError(code: "HEALTH_UNAVAILABLE", message: "Health data is unavailable", details: nil))
      return
    }

    guard let arguments = call.arguments as? [String: Any],
      let endTime = arguments["endTime"] as? NSNumber
    else {
      result(FlutterError(code: "INVALID_INTERVAL", message: "An end time is required", details: nil))
      return
    }

    let endDate = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
    if call.method == "getEarliestStepDate" {
      getEarliestStepDate(endDate: endDate, result: result)
      return
    }

    guard let startTime = arguments["startTime"] as? NSNumber,
      startTime.doubleValue < endTime.doubleValue
    else {
      result(FlutterError(code: "INVALID_INTERVAL", message: "A valid start time is required", details: nil))
      return
    }

    getDailySteps(
      startDate: Date(timeIntervalSince1970: startTime.doubleValue / 1000),
      endDate: endDate,
      result: result
    )
  }

  // Reads just the oldest accessible sample without downloading the entire history
  func getEarliestStepDate(endDate: Date, result: @escaping FlutterResult) {
    let query = HKSampleQuery(
      sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
      predicate: HKQuery.predicateForSamples(withStart: nil, end: endDate, options: []),
      limit: 1,
      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
    ) { _, samples, error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "STEPS_HISTORY_ERROR", message: error.localizedDescription, details: nil))
        } else {
          result(samples?.first.map { Int64($0.startDate.timeIntervalSince1970 * 1000) })
        }
      }
    }
    healthStore.execute(query)
  }

  // Aggregates step totals by local calendar day with HealthKit source reconciliation
  func getDailySteps(startDate: Date, endDate: Date, result: @escaping FlutterResult) {
    let query = HKStatisticsCollectionQuery(
      quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
      quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: []),
      options: .cumulativeSum,
      anchorDate: Calendar.current.startOfDay(for: startDate),
      intervalComponents: DateComponents(day: 1)
    )

    query.initialResultsHandler = { _, collection, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "STEPS_HISTORY_ERROR", message: error.localizedDescription, details: nil))
        }
        return
      }

      var rows = [[String: Int64]]()
      collection?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
        // Exclude the next batch's midnight bucket at the interval boundary
        if statistics.startDate >= startDate && statistics.startDate < endDate {
          rows.append([
            "date": Int64(statistics.startDate.timeIntervalSince1970 * 1000),
            "steps": Int64(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0),
          ])
        }
      }

      let dailySteps = rows
      DispatchQueue.main.async {
        result(dailySteps)
      }
    }
    healthStore.execute(query)
  }
}

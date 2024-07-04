//
//  FullForecastViewHelper.swift
//  Weather
//
//  Created by jonathan saville on 19/06/2024.
//

import Foundation
import WeatherNetworkingKit

/// This helper defines instance rather than static functions because of the need to access the forecast object - it would be slow if we needed to pass this into a static function, especially as they are called
/// as a result of manual scrolling. Compare this with static functions in SummaryForecastViewHelper - that helper only contains very simple method signatures (only passing Ints).
struct FullForecastViewHelper: Equatable {
    let numElementsPerScreen = 6
    
    let forecast: Forecast
    let calendar: Calendar

    init(forecast: Forecast) {
        self.forecast = forecast

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: forecast.timezoneOffset)!
        self.calendar = calendar
    }

    var hourlyForecasts: [HourlyForecast] { forecast.hourly }
    var dailyForecasts: [DailyForecast] { forecast.daily }

    func indexForScrollRight(from hourlyIndex: Int?) -> Int {
        guard let hourlyIndex = hourlyIndex else { return 0 }
        var indexDelta = 0
        var separatorCount = 0
        var newIndex = 0
        
        while abs(indexDelta) + separatorCount <= numElementsPerScreen - 1 {
            newIndex = indexDelta + hourlyIndex
            if newIndex == hourlyForecasts.count - 1 { break }
            separatorCount += shouldDisplaySeparator(for: newIndex) ? 1 : 0
            indexDelta += 1
        }
        newIndex -= (shouldDisplaySeparator(for: newIndex) ? 1 : 0)
        return min(hourlyForecasts.count - 1, newIndex + 1)
    }
    
    func indexForScrollLeft(from hourlyIndex: Int?) -> Int {
        guard let hourlyIndex = hourlyIndex else { return 0 }
        var indexDelta = -1
        var separatorCount = 0
        var newIndex = 0
        
        while abs(indexDelta) + separatorCount <= numElementsPerScreen {
            newIndex = indexDelta + hourlyIndex
            if newIndex == 0 { break }
            separatorCount += shouldDisplaySeparator(for: newIndex) ? 1 : 0
            indexDelta -= 1
        }
        return max(0, newIndex)
    }
    
    func shouldDisplaySeparator(for index: Int) -> Bool {
        guard let hourlyForecast = hourlyForecasts[safe: index] else { return false }
        let isFirstForecast = hourlyForecasts.first?.id == hourlyForecast.id
        return hourlyForecast.isFirstForecastOfDay && !isFirstForecast
    }
    
    func hourlyScrollIndex(for day: Int) -> Int {
        hourlyForecasts.firstIndex(where: { calendar.isDate(forecast.daily[day].date, inSameDayAs: $0.date) }) ?? 0
    }

    func dailyScrollIndex(for hour: Int) -> Int {
        dailyForecasts.firstIndex(where: { calendar.isDate(forecast.hourly[hour].date, inSameDayAs: $0.date) }) ?? 0
    }
    
    
    func isLeftButtonEnabled(forIndex index: Int?) -> Bool {
        (index ?? 0) > 0
    }
    
    func isRightButtonEnabled(forIndex index: Int?) -> Bool {
        indexForScrollRight(from: index ?? 0) < hourlyForecasts.count - 1
    }
}

//
//  HomeFeature.swift
//  ios-quite
//
//  Created by GitHub Copilot on 10/07/2025.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var todayConsumption: Int = 0
        var weeklyAverage: Double = 0.0
        var previousWeekAverage: Double = 0.0
        var isDebugMode: Bool = false
        var substanceType: String = "Coffee"
        var isLoading: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case consumptionTapped
        case loadTodayData
        case loadWeeklyStats
        case consumptionLogged(success: Bool)
        case dataLoaded(todayCount: Int, weeklyAvg: Double, prevWeekAvg: Double)
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.consumptionClient) var consumptionClient
    @Dependency(\.date.now) var now
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isDebugMode = authClient.isDebugMode()
                return .merge(
                    .send(.loadTodayData),
                    .send(.loadWeeklyStats)
                )
                
            case .consumptionTapped:
                state.isLoading = true
                
                if state.isDebugMode {
                    // In debug mode, simulate adding consumption
                    state.todayConsumption += 1
                    return .send(.consumptionLogged(success: true))
                } else {
                    // In production mode, log consumption via ConsumptionClient
                    return .run { [substance = state.substanceType] send in
                        do {
                            try await consumptionClient.logConsumption(substance, 1.0, "unit", 0.0)
                            await send(.consumptionLogged(success: true))
                        } catch {
                            await send(.consumptionLogged(success: false))
                        }
                    }
                }
                
            case .loadTodayData:
                if state.isDebugMode {
                    // Generate fake data for today
                    let fakeCount = Int.random(in: 0...8)
                    state.todayConsumption = fakeCount
                    return .none
                } else {
                    // In production mode, fetch from ConsumptionClient
                    return .run { [substance = state.substanceType] send in
                        do {
                            let todayCount = try await consumptionClient.getTodayConsumption(substance)
                            await send(.dataLoaded(todayCount: todayCount, weeklyAvg: 0.0, prevWeekAvg: 0.0))
                        } catch {
                            // Handle error silently for now
                            await send(.dataLoaded(todayCount: 0, weeklyAvg: 0.0, prevWeekAvg: 0.0))
                        }
                    }
                }
                
            case .loadWeeklyStats:
                if state.isDebugMode {
                    // Generate fake weekly statistics
                    let weeklyAvg = Double.random(in: 2.0...6.0)
                    let prevWeekAvg = Double.random(in: 2.0...6.0)
                    return .send(.dataLoaded(
                        todayCount: state.todayConsumption,
                        weeklyAvg: weeklyAvg,
                        prevWeekAvg: prevWeekAvg
                    ))
                } else {
                    // In production mode, fetch from ConsumptionClient
                    return .run { [substance = state.substanceType, currentCount = state.todayConsumption] send in
                        do {
                            let stats = try await consumptionClient.getWeeklyStats(substance)
                            await send(.dataLoaded(
                                todayCount: currentCount,
                                weeklyAvg: stats.current,
                                prevWeekAvg: stats.previous
                            ))
                        } catch {
                            // Handle error silently for now
                            await send(.dataLoaded(
                                todayCount: currentCount,
                                weeklyAvg: 0.0,
                                prevWeekAvg: 0.0
                            ))
                        }
                    }
                }
                
            case let .consumptionLogged(success):
                state.isLoading = false
                if success {
                    // Refresh today's data
                    return .send(.loadTodayData)
                } else {
                    // Handle error (could show an alert)
                    return .none
                }
                
            case let .dataLoaded(todayCount, weeklyAvg, prevWeekAvg):
                state.todayConsumption = todayCount
                state.weeklyAverage = weeklyAvg
                state.previousWeekAverage = prevWeekAvg
                return .none
            }
        }
    }
}



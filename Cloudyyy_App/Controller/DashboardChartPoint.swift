//
//  DashboardChartPoint.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/11/25.
//


import SwiftUI
import Charts

@available(iOS 16.0, *)
struct DashboardChartPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let rewards: Int
    let tasks: Int
}

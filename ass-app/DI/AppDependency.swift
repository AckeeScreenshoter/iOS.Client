//
//  AppDependency.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import Foundation

protocol HasNoDependency { }

final class AppDependency: HasNoDependency, HasScreenshotAPI {
    let screenshotAPI: ScreenshotAPIServicing = ScreenshotAPIService()
}

let dependencies = AppDependency()

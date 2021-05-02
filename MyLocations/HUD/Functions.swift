//
//  Functions.swift
//  MyLocations
//
//  Created by Tolga PIRTURK on 29.04.2021.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

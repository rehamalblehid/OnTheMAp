//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Reham on 28/12/2018.
//  Copyright © 2018 Reham. All rights reserved.
//

import Foundation
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

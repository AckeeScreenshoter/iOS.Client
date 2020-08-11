//
//  Media.swift
//  ass-app
//
//  Created by Vendula Švastalová on 31/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import Foundation
import UIKit

public enum Media {
    case screenshot(UIImage?)
    case record(URL?)
    
    var id: String {
        switch self {
        case .screenshot:
            return "screenshot"
        case .record:
            return "record"
        }
    }
}

extension Media {
    init?(string: String) {
        switch string {
        case "screenshot":
            self = .screenshot(nil)
        case "record":
            self = .record(nil)
        default:
            return nil
        }
    }
}

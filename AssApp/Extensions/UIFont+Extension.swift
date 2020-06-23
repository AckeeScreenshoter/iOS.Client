//
//  UIFont+Extension.swift
//  ass-app
//
//  Created by Vendula Švastalová on 10/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

extension UIFont {
    static func overpassMonoRegular(size: CGFloat) -> UIFont {
        _ = fonts
        return UIFont(name: "OverpassMono-Regular", size: size)!
    }
}

private final class BundleLocator {}
private let fonts: [URL] = {
    print("initialized fonts")
    let bundleURL = Bundle(for: BundleLocator.self).resourceURL!
    let resourceURLs = try? FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
    let fonts = resourceURLs?.filter { $0.pathExtension == "otf" || $0.pathExtension == "ttf" } ?? []

    fonts.forEach { CTFontManagerRegisterFontsForURL($0 as CFURL, CTFontManagerScope.process, nil) }

    return fonts
}()

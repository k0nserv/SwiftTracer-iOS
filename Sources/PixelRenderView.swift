//
//  PixelRenderView.swift
//  SwiftTracer-iOS
//
//  Created by Hugo Tunius on 30/01/16.
//  Copyright © 2016 Hugo Tunius. All rights reserved.
//

import UIKit
import SwiftTracer_Core

class PixelRenderView: UIView {
    var pixels: [Color] = [] {
        didSet {
            rawPixels = UnsafeMutablePointer<UInt8>(pixels)
            rawPixelsLength = pixels.count * (sizeof(Color)/sizeof(UInt8))
        }
    }
    private var rawPixelsLength: Int = 0
    private var rawPixels: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>()

    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)
        if pixels.count == 0 {
            return
        }

        guard let colorSpace = CGColorSpaceCreateDeviceRGB() else {
            return
        }
        guard let scale = window?.screen.scale else {
            return
        }

        let dataProvider = CGDataProviderCreateWithCFData(
            NSData(bytes: rawPixels, length: rawPixelsLength)
        )
        let i = CGImageCreate(
            Int(bounds.size.width) * Int(scale),
            Int(bounds.size.height) * Int(scale),
            8,
            32,
            sizeof(Color) * Int(bounds.size.width) * Int(scale),
            colorSpace,
            CGBitmapInfo.ByteOrder32Big,
            dataProvider,
            nil,
            true,
            CGColorRenderingIntent.RenderingIntentDefault)

        guard let image = i else {
            return
        }

        let uiimage = UIImage.init(CGImage: image)
        uiimage.drawInRect(self.bounds)
    }
}
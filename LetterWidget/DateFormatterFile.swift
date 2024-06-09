//
//  DateFormatterFile.swift
//  LetterWidgetExtension
//
//  Created by Sangmok Choi on 2023/04/05.
//

import Foundation
import UIKit

extension UIColor {
    
    func hexColorExtract(BackgroundColor: UIView) -> String {
        
        let backgroundColor = BackgroundColor.backgroundColor
        // Convert the UIColor object to its RGB components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Format the RGB components as a hexadecimal string
        let hexColor = String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
        print("The hexadecimal color value of the view's background color is #\(hexColor).")
        return hexColor
    }
    
    convenience init?(hex: String) {
        //let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        let red, green, blue: CGFloat
        switch hex.count {
        case 6:
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        default:
            return nil
        }
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

class DateFormatterFile {
    func dateFormatting(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let convertDate = dateFormatter.string(from: date)
        return convertDate
    }
}

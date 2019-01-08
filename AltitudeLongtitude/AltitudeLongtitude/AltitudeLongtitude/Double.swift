//
//  Double.swift
//  AltitudeLongtitude
//
//  Created by Nick Slobodsky on 26/10/2018.
//  Copyright © 2018 Nick Slobodsky. All rights reserved.
//

import Foundation


extension Double
{
    func rounded(toDecimalPlaces places : Int) -> Double {
        
        let divisor = pow(10, Double(places))
        
        return (self * divisor).rounded() / divisor 
        
    }
}

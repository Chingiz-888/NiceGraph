//
//  CubicCurvedPath.swift
//  Bezier
//
//  Created by Чингиз Б on 02.07.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit



class CubicCurvedPath {
    

    private var data: [CGPoint] = []
    
    init(data : [CGPoint]) {
        self.data     = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func cubicCurvedPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        var p1 = data[0]
        path.move(to: p1)
        var oldControlP = p1
        
        for i in 0..<data.count {
            let p2 = data[i]
            var p3: CGPoint? = nil
            if i < data.count - 1 {
                p3 = data [i+1]
            }
            
            let newControlP = controlPointForPoints(p1: p1, p2: p2, p3: p3)
            //uncomment the following four lines to graph control points
            //if let controlP = newControlP {
            //    path.drawWithLine(point:controlP, color: UIColor.blue)
            //}
            //path.drawWithLine(point:oldControlP, color: UIColor.gray)
            
            path.addCurve(to: p2, controlPoint1: oldControlP , controlPoint2: newControlP ?? p2)
            oldControlP = imaginFor(point1: newControlP, center: p2) ?? p1
            //***added to algorithm
            if let p3 = p3 {
                if oldControlP.x > p3.x { oldControlP.x = p3.x }
            }
            //***
            p1 = p2
        }
        return path;
    }
    
    private func imaginFor(point1: CGPoint?, center: CGPoint?) -> CGPoint? {
        //returns "mirror image" of point: the point that is symmetrical through center.
        //aka opposite of midpoint; returns the point whose midpoint with point1 is center)
        guard let p1 = point1, let center = center else {
            return nil
        }
        let newX = center.x + center.x - p1.x
        let newY = center.y + center.y - p1.y
        
        return CGPoint(x: newX, y: newY)
    }
    
    private func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2);
    }
    
    private func clamp(num: CGFloat, bounds1: CGFloat, bounds2: CGFloat) -> CGFloat {
        //ensure num is between bounds.
        if (bounds1 < bounds2) {
            return min(max(bounds1,num),bounds2);
        } else {
            return min(max(bounds2,num),bounds1);
        }
    }
    
    private func controlPointForPoints(p1: CGPoint, p2: CGPoint, p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }
        
        let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
        let rightMidPoint = midPointForPoints(p1: p2, p2: p3)
        let imaginPoint = imaginFor(point1: rightMidPoint, center: p2)
        
        var controlPoint = midPointForPoints(p1: leftMidPoint, p2: imaginPoint!)
        
        controlPoint.y = clamp(num: controlPoint.y, bounds1: p1.y, bounds2: p2.y)
        
        let flippedP3 = p2.y + (p2.y-p3.y)
        
        controlPoint.y = clamp(num: controlPoint.y, bounds1: p2.y, bounds2: flippedP3);
        //***added:
        controlPoint.x = clamp (num:controlPoint.x, bounds1: p1.x, bounds2: p2.x)
        //***
        // print ("p1: \(p1), p2: \(p2), p3: \(p3), LM:\(leftMidPoint), RM:\(rightMidPoint), IP:\(imaginPoint), fP3:\(flippedP3), CP:\(controlPoint)")
        return controlPoint
    }

    
    
    
}

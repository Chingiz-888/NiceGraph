//
//  ViewController.swift
//  Bezier
//
//  Created by Ramsundar Shandilya on 10/12/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // вот тут этот кастомный объект типа BezierView!
    // мы ему посылаем сигнал на  self.firstBezierView.layoutSubviews()
    @IBOutlet weak var firstBezierView: BezierView!
   
    // по логике программы не должно быть > 255
    // также у нас ограничения по self.firstBezierView.frame.width.f  и 
    // self.firstBezierView.frame.height.f
    let dataPoints = [252, 220, 101, 2, 101, 220, 252]
    
    var xAxisPoints : [Double] {
        var points = [Double]()
        for i in 0..<dataPoints.count {
            let val = (Double(i)/6.0) * self.firstBezierView.frame.width.f
            points.append(val)
        }
        
        return points
    }
    
    var yAxisPoints: [Double] {
        var points = [Double]()
        for i in dataPoints {
            let val = (Double(i)/255) * self.firstBezierView.frame.height.f
            points.append(val)
        }
        
        return points
    }
    
    // Эта переменная-массив наполняется замыканием, что возвращает массив [CGPoint], пролучаемые из отмапенных на доступную для графика
    // и на равные доли от количества точек на экране (в программе их 6) область
    var graphPoints : [CGPoint] {
        var points = [CGPoint]()
        for i in 0..<dataPoints.count {
            let val = CGPoint(x: self.xAxisPoints[i], y: self.yAxisPoints[i])
            points.append(val)
        }
        
        return points
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstBezierView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.firstBezierView.layoutSubviews()
    }

    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        self.firstBezierView.layoutSubviews()
    }
    
    
}

extension ViewController: BezierViewDataSource {
    
    func bezierViewDataPoints(_ bezierView: BezierView) -> [CGPoint] {
        
        return graphPoints
    }
}


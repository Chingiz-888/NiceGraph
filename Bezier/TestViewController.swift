//
//  TestViewController.swift
//  Bezier
//
//  Created by Чингиз Б on 28.06.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit
import ANDLineChartView

class TestViewController: UIViewController, ANDLineChartViewDataSource, ANDLineChartViewDelegate {

    let MAX_NUMBER_COUNT  = 150
    let MAX_NUMBER = 20
    
    var _elements : [Int] = [Int]()
    var _chartView : ANDLineChartView?
    var _maxValue : Int = Int()
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _chartView = ANDLineChartView(frame: CGRect.zero)
        _chartView?.translatesAutoresizingMaskIntoConstraints = false
        _chartView?.dataSource = self
        _chartView?.delegate   = self
        _chartView?.animationDuration = 0.4
        self.view.addSubview(_chartView!)
        
        _elements = self.arrayWithRandomNumbers()
        //self.setupConstraints()
        
    
    }


    
    
    func arrayWithRandomNumbers() -> [Int] {
        let _numbersCount = MAX_NUMBER_COUNT;//arc4random_uniform(MAX_NUMBER_COUNT + 1) + 1;
        let _maxValue = MAX_NUMBER;//arc4random_uniform(MAX_NUMBER + 1);
        
        var xxx = [Int]()
        
        
        for i in 0..<_numbersCount {
            var r : UInt = UInt(arc4random_uniform( UInt32(_maxValue + 1)   )   )
            xxx.append(Int(r))
        }
        return xxx
    }
    
    
    
    
    func setupConstraints() {
        
        let topLayoutGuide = self.view.topAnchor;
            let d = dictionaryOfNames(arr: _chartView!)
       
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide][_chartView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: d)
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[_chartView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: d)
        
         self.view.addConstraints(constraints1)
         self.view.addConstraints(constraints2)
    }
    
    
    func dictionaryOfNames(arr:UIView...) -> Dictionary<String,UIView> {
        var d = Dictionary<String,UIView>()
        for (ix,v) in arr.enumerated(){
            d["v\(ix+1)"] = v
        }
        return d
    }
    
    
    
    
    
    
    
    
    
    
    
    func numberOfElements(in chartView: ANDLineChartView!) -> UInt {
        return 0//UInt(MAX_NUMBER_COUNT)
    }
    
    func chartView(_ chartView: ANDLineChartView!, valueForElementAtRow row: UInt) -> CGFloat {
         return CGFloat( (_elements[Int(row)]) )
    }
    
    func maxValueForGridInterval(in chartView: ANDLineChartView!) -> CGFloat {
        return CGFloat(_maxValue);
    }
    
    func minValueForGridInterval(in chartView: ANDLineChartView!) -> CGFloat {
        return -2.0
    }
    
    func numberOfGridIntervals(in chartView: ANDLineChartView!) -> UInt {
        return UInt(12.0)
    }
    
    func chartView(_ chartView: ANDLineChartView!, descriptionForGridIntervalValue interval: CGFloat) -> String! {
        return  String.init(format: "%.1f", interval)
    }
    
    
    func chartView(_ chartView: ANDLineChartView!, spacingForElementAtRow row: UInt) -> CGFloat {
          return (row == 0) ? 60.0 : 30.0
    }

}

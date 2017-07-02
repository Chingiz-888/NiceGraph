//
//  TestViewController.swift
//  Bezier
//
//  Created by Чингиз Б on 28.06.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit


class TestViewController: UIViewController {

    
    @IBOutlet weak var viewForChart: UIView!

       
    
    var MAX_NUMBER_COUNT     = Int()
    var MAX_NUMBER           = Int() {
        didSet {
            EXTRA_TO_MAX_NUMBER = Int(round((Float(self.MAX_NUMBER) * 0.18)))
        }
    }
    var EXTRA_TO_MAX_NUMBER = Int()
   
    
    var _elements : [Int] = [Int]()
    var _chartView : ANDLineChartView?
    var _maxValue     : Int  = Int()
    var _numbersCount : Int  = Int()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MAX_NUMBER_COUNT = 888
        MAX_NUMBER = 20
     
        
        _maxValue     = self.MAX_NUMBER
        _numbersCount = self.MAX_NUMBER_COUNT;
        _chartView = ANDLineChartView(frame: CGRect.zero)
        _chartView?.translatesAutoresizingMaskIntoConstraints = false
        _chartView?.dataSource        = self
        _chartView?.delegate          = self
        _chartView?.animationDuration = 0.4
        
        // вариант 1 - chartView добавляется прямо на superview - self.view
        // self.view.addSubview(_chartView!)
        
        // вариант 2 - chartView добавляется на view-подложку
        self.viewForChart.addSubview(_chartView!)
        
        _elements = self.arrayWithRandomNumbers()
        self.setupConstraints()
    }


    
    
    func arrayWithRandomNumbers() -> [Int] {
        var xxx = [Int]()
        
        for i in 0..<_numbersCount {
            var r : UInt = UInt(arc4random_uniform( UInt32(_maxValue + 1)   )   )
            xxx.append(Int(r))
        }
        return xxx
    }
    
    
    
    
    func setupConstraints() {
       
        // вариант 1 - chartView добавляется прямо на superview - self.view
        /*let topLayoutGuide =  self.topLayoutGuide
        let views: [String: AnyObject] = ["_chartView"    : _chartView!,
                                          "topLayoutGuide": topLayoutGuide]*/
        //let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-20-[_chartView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        //let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[_chartView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        // self.view.addConstraints(constraints1)
        // self.view.addConstraints(constraints2)
        
        
        // вариант 2 - chartView добавляется на view-подложку
        let views: [String: AnyObject] = [ "viewForChart"  : viewForChart,
                                           "_chartView"    : _chartView!
                                          ]
        
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-10)-[_chartView]-(-10)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-10)-[_chartView]-(-10)-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        self.viewForChart.addConstraints(constraints1)
        self.viewForChart.addConstraints(constraints2)
       
    }
}//----- end of class declaration -----------------






// MARK:   Methods of ANDLineChartViewDataSource protoocol ----------------------------
extension TestViewController : ANDLineChartViewDataSource {
    func chartView(_ chartView: ANDLineChartView, valueForElementAtRow row: Int) -> CGFloat? {
        return CGFloat( _elements[row] )
    }
    
    func numberOfElements(in chartView: ANDLineChartView) -> Int? {
        return MAX_NUMBER_COUNT
    }
    
    func numberOfGridIntervals(in chartView: ANDLineChartView) -> Int? {
        return Int(12.0)
    }
    
    // Форматированные подписи к Y-оси
    func chartView(_ chartView: ANDLineChartView, descriptionForGridIntervalValue interval: CGFloat) -> String {
        return  String.init(format: "%.1f", interval)
    }
    
    func maxValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat? {
        return CGFloat(self.MAX_NUMBER + self.EXTRA_TO_MAX_NUMBER)   //!!! добавляем еще сверху, чтобы верхние надписи к значениемям были видны
    }
    
    func minValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat? {
        return  -2.0 - CGFloat(self.EXTRA_TO_MAX_NUMBER)              //!!! снизу езе убираем, чтобы были видны подпсии к датам
    }
}//--------------------------------------------------------------------------------------


// MARK:   Methods of ANDLineChartViewDelegate protoocol ----------------------------
extension TestViewController : ANDLineChartViewDelegate {
    func chartView(_ chartView: ANDLineChartView, spacingForElementAtRow row: Int) -> CGFloat {
       return (row == 0) ? 60.0 : 30.0
    }
}




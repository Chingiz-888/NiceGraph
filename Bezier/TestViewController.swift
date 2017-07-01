//
//  TestViewController.swift
//  Bezier
//
//  Created by Чингиз Б on 28.06.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit


class TestViewController: UIViewController {

    let MAX_NUMBER_COUNT  = 150
    let MAX_NUMBER = 20
    
    var _elements : [Int] = [Int]()
    var _chartView : ANDLineChartView?
    var _maxValue     : Int  = Int()
    var _numbersCount : Int  = Int()

    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _maxValue     = self.MAX_NUMBER
        _numbersCount = self.MAX_NUMBER_COUNT;

        _chartView = ANDLineChartView(frame: CGRect.zero)
        _chartView?.translatesAutoresizingMaskIntoConstraints = false
        _chartView?.dataSource = self
        _chartView?.delegate   = self
        _chartView?.animationDuration = 0.4
        self.view.addSubview(_chartView!)
        
        _elements = self.arrayWithRandomNumbers()
        self.setupConstraints()
        
    
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        
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
        
        let topLayoutGuide = self.topLayoutGuide
       
        let views: [String: AnyObject] = ["_chartView"    : _chartView!,
                                          "topLayoutGuide": topLayoutGuide
                                          ]
       
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-20-[_chartView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[_chartView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
         self.view.addConstraints(constraints1)
         self.view.addConstraints(constraints2)
    }
    
    
    // мне не нужжно - можно руками наполнить массив вью
    // let d = dictionaryOfNames(arr: _chartView!)
//    func dictionaryOfNames(arr:UIView...) -> Dictionary<String,UIView> {
//        var d = Dictionary<String,UIView>()
//        for (ix,v) in arr.enumerated(){
//            d["v\(ix+1)"] = v
//        }
//        return d
//    }
    

}//----- end of class declaration -----------------






// MARK:   Methods of ANDLineChartViewDataSource protoocol ----------------------------
extension TestViewController : ANDLineChartViewDataSource {
    func numberOfElements(in chartView: ANDLineChartView) -> Int? {
        return MAX_NUMBER_COUNT
    }
    
    func numberOfGridIntervals(in chartView: ANDLineChartView) -> Int? {
        return Int(12.0)
    }
    
    func chartView(_ chartView: ANDLineChartView, valueForElementAtRow row: Int) -> CGFloat? {
        return CGFloat( (_elements[Int(row)]) )
    }
    
    // Values may be displayed differently eg. One might want to present 4200 seconds as 01h:10:00
    func chartView(_ chartView: ANDLineChartView, descriptionForGridIntervalValue interval: CGFloat) -> String {
        return  String.init(format: "%.1f", interval)
    }
    
    func maxValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat? {
        return CGFloat(_maxValue)
    }
    
    func minValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat? {
        return -2.0
    }
}//--------------------------------------------------------------------------------------


// MARK:   Methods of ANDLineChartViewDelegate protoocol ----------------------------
extension TestViewController : ANDLineChartViewDelegate {
    func chartView(_ chartView: ANDLineChartView, spacingForElementAtRow row: Int) -> CGFloat {
       return (row == 0) ? 60.0 : 30.0
    }
}




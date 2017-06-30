//
//  ANDLineChartView.swift
//  Bezier
//
//  Created by Чингиз Б on 01.07.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit



protocol ANDLineChartViewDataSource: NSObjectProtocol {
    func numberOfElements(in chartView: ANDLineChartView) -> Int
    
    func numberOfGridIntervals(in chartView: ANDLineChartView) -> Int
    
    func chartView(_ chartView: ANDLineChartView, valueForElementAtRow row: Int) -> CGFloat
    
    // Values may be displayed differently eg. One might want to present 4200 seconds as 01h:10:00
    func chartView(_ chartView: ANDLineChartView, descriptionForGridIntervalValue interval: CGFloat) -> String
    
    func maxValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat
    
    func minValueForGridInterval(in chartView: ANDLineChartView) -> CGFloat
}

protocol ANDLineChartViewDelegate: NSObjectProtocol {
    // you can specify spacing from previous element to element at current row. If it is first element, spacing is computed
    // from left border of view.
    // if you want to have the same spacing between every element, use elementSpacing property from ANDGraphView
    func chartView(_ chartView: ANDLineChartView, spacingForElementAtRow row: Int) -> CGFloat
}




class ANDLineChartView: UIView, UIScrollViewDelegate {
    
    let DEFAULT_ELEMENT_SPACING = 30.0
    let DEFAULT_FONT_SIZE = 12.0
    let TRANSITION_DURATION = 0.36

    
    weak var dataSource : ANDLineChartViewDataSource?
    weak var delegate   : ANDLineChartViewDelegate?
    

    var gridIntervalFont: UIFont?
    var chartBackgroundColor: UIColor?
    // default is [UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]
    var gridIntervalLinesColor: UIColor?
    // default is [UIColor colorWithRed:0.325 green:0.314 blue:0.627 alpha:1.000]
    var gridIntervalFontColor: UIColor?
    // default is [UIColor colorWithRed:0.216 green:0.204 blue:0.478 alpha:1.000]
    var elementFillColor: UIColor?
    // default is [UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]
    var elementStrokeColor: UIColor?
    // default is [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
    var lineColor: UIColor?
    // default is [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
    var elementSpacing: CGFloat = 0.0
    //default is 30
    var animationDuration = TimeInterval()
    //default is 0.36
  
    var isShouldLabelsFloat: Bool = true    //default YES
    
 
    
    
    private var scrollView: UIScrollView?
    private var internalChartView: ANDInternalLineChartView?
    private var backgroundChartView: ANDBackgroundChartView?
    private var floatingConstraint: NSLayoutConstraint?
    private var backgroundWidthEqualToScrollViewConstraints: NSLayoutConstraint?
    private var backgroundWidthEqualToChartViewConstraints: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = UIScrollView(frame: CGRect.zero)
        internalChartView = ANDInternalLineChartView(frame: CGRect.zero, chartContainer: self)
        backgroundChartView = ANDBackgroundChartView(frame: CGRect.zero, chartContainer: self)
        scrollView?.addSubview(backgroundChartView!)
        scrollView?.addSubview(internalChartView!)
        addSubview(scrollView!)
        setupDefaultAppearence()
        setupInitialConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDefaultAppearence() {
        chartBackgroundColor = UIColor(red: CGFloat(0.39), green: CGFloat(0.38), blue: CGFloat(0.67), alpha: CGFloat(1.0))
        backgroundColor = chartBackgroundColor
        lineColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(1))
        elementFillColor = chartBackgroundColor
        elementStrokeColor = UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(1))
        gridIntervalLinesColor = UIColor(red: CGFloat(0.325), green: CGFloat(0.314), blue: CGFloat(0.627), alpha: CGFloat(1.000))
        gridIntervalFontColor = UIColor(red: CGFloat(0.216), green: CGFloat(0.204), blue: CGFloat(0.478), alpha: CGFloat(1.000))
        gridIntervalFont = UIFont(name: "HelveticaNeue", size: CGFloat(DEFAULT_FONT_SIZE))
        elementSpacing = CGFloat(DEFAULT_ELEMENT_SPACING)
        animationDuration(TRANSITION_DURATION)
        shouldLabelsFloat = true
    }
    
    func setupInitialConstraints() {
        scrollView?.translatesAutoresizingMaskIntoConstraints           = false
        internalChartView?.translatesAutoresizingMaskIntoConstraints    = false
        backgroundChartView?.translatesAutoresizingMaskIntoConstraints  = false
        
        // declare dictionary of our view for constraint implementation, all is just simple
        let viewsDict: [String: AnyObject] = ["_scrollView"          : scrollView!,
                                              "_internalChartView"   : internalChartView!,
                                              "_backgroundChartView" : backgroundChartView!
                                             ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_scrollView]|", options: [], metrics: nil, views: viewsDict as! [String : Any]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_scrollView]|", options: [], metrics: nil, views: viewsDict as! [String : Any]))
        scrollView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_internalChartView]|", options: [], metrics: nil, views: viewsDict as! [String : Any]))
        scrollView?.addConstraint(NSLayoutConstraint(item: internalChartView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0))
        scrollView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_internalChartView]|", options: [], metrics: nil, views: viewsDict as! [String : Any]))
        scrollView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_backgroundChartView]|", options: [], metrics: nil, views: viewsDict as! [String : Any]))
        floatingConstraint = NSLayoutConstraint(item: backgroundChartView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        // ДОБАВЛЕНИЕ WIDTH CONSTRAINT
        backgroundWidthEqualToScrollViewConstraints = NSLayoutConstraint(item: backgroundChartView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0)
        backgroundWidthEqualToChartViewConstraints = NSLayoutConstraint(item: backgroundChartView, attribute: .width, relatedBy: .equal, toItem: internalChartView, attribute: .width, multiplier: 1.0, constant: 0.0)
        if isShouldLabelsFloat {
            addConstraint(floatingConstraint!)
            scrollView?.addConstraint(backgroundWidthEqualToScrollViewConstraints!)
        }
        else {
            scrollView?.addConstraint(backgroundWidthEqualToChartViewConstraints!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        internalChartView?.preferredMinLayoutWidth = frame.width
    }
    
    func reloadData() {
        backgroundChartView?.setNeedsDisplay()
        internalChartView?.reloadData()
    }
    
    func setShouldLabelsFloat(_ shouldLabelsFloat: Bool) {
        if isShouldLabelsFloat == shouldLabelsFloat {
            return
        }
        if isShouldLabelsFloat {
            removeConstraint(floatingConstraint!)
            scrollView?.removeConstraint(backgroundWidthEqualToScrollViewConstraints!)
        }
        else {
            scrollView?.removeConstraint(backgroundWidthEqualToChartViewConstraints!)
        }
        if isShouldLabelsFloat {
            addConstraint(floatingConstraint!)
            scrollView?.addConstraint(backgroundWidthEqualToScrollViewConstraints!)
        }
        else {
            scrollView?.addConstraint(backgroundWidthEqualToChartViewConstraints!)
        }
        isShouldLabelsFloat = shouldLabelsFloat
        setNeedsUpdateConstraints()
    }
    
    // MARK: -
    // MARK: - ANDInternalLineChartViewDataSource methods
    func spacingForElement(atRow row: Int) -> CGFloat {
        var spacing: CGFloat = elementSpacing
        if (delegate != nil) && (delegate?.responds(to: Selector("chartView:spacingForElementAtRow:")))! {
            var newSpacing: CGFloat = delegate!.chartView(self, spacingForElementAtRow: row)
            assert(newSpacing > 0, "Spacing cannot be smaller than 0.0")
            let imageSize: CGSize? = internalChartView?.circleImage?.size
            newSpacing += (row == 0) ? (imageSize?.width)! / 2.0 : (imageSize?.width)!
            if newSpacing > 0 {
                spacing = newSpacing
            }
        }
        return spacing
    }
    
    func numberOfElements() -> Int {
        if (dataSource != nil) && dataSource!.responds(to: #selector(self.numberOfElementsInChartView)) {
            return dataSource!.numberOfElements(in: self)
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert(dataSource!.responds(to: #selector(self.numberOfElementsInChartView)), "numberOfElementsInChartView: not implemented.")
            return 0
        }
    }
    
    func numberOfIntervalLines() -> Int {
        if (dataSource != nil) && dataSource!.responds(to: #selector(self.numberOfGridIntervalsInChartView)) {
            return dataSource!.numberOfGridIntervals(in: self)
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert(dataSource!.responds(to: #selector(self.numberOfGridIntervalsInChartView)), "numberOfGridIntervalsInChartView: not implemented.")
            return 0
        }
    }
    
    func valueForElement(atRow row: Int) -> CGFloat {
        if (dataSource != nil) && (dataSource?.responds(to: Selector("chartView:valueForElementAtRow:")))! {
            let value: CGFloat = dataSource!.chartView(self, valueForElementAtRow: row)
            assert(value >= minValue() && value <= maxValue(), "Value for element \(UInt(row)) (\(value)) is not in min/max range")
            return value
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert((dataSource?.responds(to: Selector("chartView:valueForElementAtRow:")))!, "chartView:valueForElementAtRow: not implemented.")
            return 0.0
        }
    }
    
    func minValue() -> CGFloat {
        if (dataSource != nil) && dataSource!.responds(to: #selector(self.minValueForGridIntervalInChartView)) {
            let minValue: CGFloat = dataSource!.minValueForGridInterval(in: self)
            assert(minValue < maxValue(), "minimal value cannot be bigger than max value")
            return minValue
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert(dataSource!.responds(to: #selector(self.minValueForGridIntervalInChartView)), "minValueForGridIntervalInChartView: not implemented.")
            return 0.0
        }
    }
    
    func maxValue() -> CGFloat {
        if (dataSource != nil) && dataSource!.responds(to: #selector(self.maxValueForGridIntervalInChartView)) {
            return dataSource!.maxValueForGridInterval(in: self)
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert(dataSource!.responds(to: #selector(self.maxValueForGridIntervalInChartView)), "maxValueForGridIntervalInChartView: not implemented.")
            return 0.0
        }
    }
    
    func description(forValue value: CGFloat) -> String {
        if (dataSource != nil) && (dataSource?.responds(to: Selector("chartView:descriptionForGridIntervalValue:")))! {
            return dataSource!.chartView(self, descriptionForGridIntervalValue: value)
        }
        else {
            assert((dataSource != nil), "Data source is not set.")
            assert((dataSource?.responds(to: Selector("chartView:descriptionForGridIntervalValue:")))!, "chartView:descriptionForGridIntervalValue: not implemented.")
            return ""
        }
    }
    
    
    

}//---- end of class ------------------------------

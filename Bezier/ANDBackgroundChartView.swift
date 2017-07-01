//
//  ANDBackgroundChartView.swift
//  Bezier
//
//  Created by Чингиз Б on 01.07.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit

class ANDBackgroundChartView: UIView {
    
    let INTERVAL_TEXT_LEFT_MARGIN = 10.0
    let INTERVAL_TEXT_MAX_WIDTH   = 100.0

    weak var chartContainer: ANDLineChartView?
    
    convenience override init(frame: CGRect) {
        assert(false, "Use initWithFrame:chartContainer:")
        self.init(frame: frame, chartContainer: nil)
    }
    
     init(frame: CGRect, chartContainer: ANDLineChartView?) {
        super.init(frame: frame)
        contentMode = .redraw
        self.chartContainer = chartContainer
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    override func draw(_ rect: CGRect) {
        let context: CGContext? = UIGraphicsGetCurrentContext()
        let boundsPath = UIBezierPath(rect: bounds)
        context?.setFillColor(chartContainer!.chartBackgroundColor?.cgColor as! CGColor)
        boundsPath.fill()
        
        let maxHeight: CGFloat = viewHeight()
        
        UIColor(red: CGFloat(0.329), green: CGFloat(0.322), blue: CGFloat(0.620), alpha: CGFloat(1.000)).setStroke()
        let gridLinePath = UIBezierPath()
        let startPoint = CGPoint(x: CGFloat(0.0), y: CGFloat(frame.height))
        let endPoint = CGPoint(x: CGFloat(rect.maxX), y: CGFloat(frame.height))
        gridLinePath.move(to: startPoint)
        gridLinePath.addLine(to: endPoint)
        gridLinePath.lineWidth = 1.0
        context?.saveGState()
        
        let numberOfIntervalLines: Int   = chartContainer!.numberOfIntervalLines()
        let intervalSpacing  : CGFloat   = maxHeight / CGFloat(numberOfIntervalLines - 1)
        let maxIntervalValue : CGFloat   = chartContainer!.maxValue()
        let minIntervalValue : CGFloat   = chartContainer!.minValue()
        let maxIntervalDiff  : CGFloat   = (maxIntervalValue - minIntervalValue) / CGFloat (numberOfIntervalLines - 1)
        
        for i in 0..<numberOfIntervalLines {
            chartContainer!.gridIntervalLinesColor?.setStroke()
            gridLinePath.stroke()
            let stringToDraw: String =   "\(minIntervalValue + CGFloat(i) * maxIntervalDiff)" // MOE: СТРОКА ДЛЯ ЗАПИСИ      //chartContainer!.description(forValue: minIntervalValue + i * maxIntervalDiff)
            let stringColor: UIColor? = chartContainer!.gridIntervalFontColor  //gridIntervalFontColor()
            
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byTruncatingTail
        
            
//            stringToDraw.draw(in: CGRect(x: CGFloat(INTERVAL_TEXT_LEFT_MARGIN),
//                                         y: CGFloat((frame.height - chartContainer!.gridIntervalFont().lineHeight)),
//                                         width: CGFloat(INTERVAL_TEXT_MAX_WIDTH),
//                                         height: CGFloat(chartContainer!.gridIntervalFont.lineHeight)),
//                              
//                              withAttributes: [NSFontAttributeName: chartContainer!.gridIntervalFont(),
//                                               NSForegroundColorAttributeName: stringColor,
//                                               NSParagraphStyleAttributeName: paragraphStyle])
            
            context?.translateBy(x: 0.0, y: -intervalSpacing)

            
        }
        
        context?.restoreGState()
    }
    
    
    
    func viewHeight() -> CGFloat {
        let font: UIFont? = chartContainer?.gridIntervalFont
        let maxHeight: CGFloat? = round(frame.height - (font?.lineHeight)!)
        return maxHeight!
    }

}//---- end of class -----------------------------------------

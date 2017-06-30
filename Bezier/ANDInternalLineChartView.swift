//
//  ANDInternalLineChartView.swift
//  Bezier
//
//  Created by Чингиз Б on 01.07.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit

class ANDInternalLineChartView: UIView {
    weak var chartContainer: ANDLineChartView?
    private(set) var circleImage: UIImage?
    // Support for constraint-based layout (auto layout)
    // If nonzero, this is used when determining -intrinsicContentSize
    var preferredMinLayoutWidth: CGFloat = 0.0
    
    let INTERVAL_TEXT_LEFT_MARGIN = 10.0
    let INTERVAL_TEXT_MAX_WIDTH = 100.0
    let CIRCLE_SIZE = 14.0
    
    
    private var graphLayer: CAShapeLayer?
    private var maskLayer: CAShapeLayer?
    private var gradientLayer: CAGradientLayer?
    private var circleImage: UIImage?
    private var numberOfPreviousElements: Int = 0
    private var maxValue: CGFloat = 0.0
    private var minValue: CGFloat = 0.0
    private var animationNeeded: Bool = false
    
    convenience init(frame: CGRect) {
        return self.init(frame: frame, chartContainer: nil)
    }
    
    init(frame: CGRect, chartContainer: ANDLineChartView) {
        super.init(frame: frame)
        
        chartContainer = chartContainer
        setupGradientLayer()
        setupMaskLayer()
        setupGraphLayer()
        backgroundColor = UIColor.clear
        opaque = false
        
    }
    
    func setupGraphLayer() {
        graphLayer = CAShapeLayer()
        graphLayer?.frame = bounds
        graphLayer?.geometryFlipped = true
        graphLayer?.strokeColor = chartContainer.lineColor().cgColor
        graphLayer?.fillColor = nil
        graphLayer?.lineWidth = 2.0
        graphLayer?.lineJoin = kCALineJoinBevel
        layer().addSublayer(graphLayer)
    }
    
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        let color1: CGColor = UIColor(white: CGFloat(1.000), alpha: CGFloat(0.7)).cgColor
        let color2: CGColor = UIColor(white: CGFloat(1.000), alpha: CGFloat(0.0)).cgColor
        gradientLayer?.colors = [(color1 as? Any), (color2 as? Any)]
        gradientLayer?.locations = [0.0, 0.9]
        gradientLayer?.frame = bounds
        layer().addSublayer(gradientLayer)
    }
    
    func setupMaskLayer() {
        maskLayer = CAShapeLayer()
        maskLayer?.frame = bounds
        maskLayer?.geometryFlipped = true
        maskLayer?.strokeColor = UIColor.clear.cgColor
        maskLayer?.fillColor = UIColor.black.cgColor
        maskLayer?.lineWidth = 2.0
        maskLayer?.lineJoin = kCALineJoinBevel
        maskLayer?.masksToBounds = true
    }
    
    func reloadData() {
        animationNeeded = true
        let numberOfPoints: Int = chartContainer.numberOfElements()
        if numberOfPoints != numberOfPreviousElements {
            invalidateIntrinsicContentSize()
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        graphLayer?.frame = bounds
        maskLayer?.frame = bounds
        gradientLayer?.frame = bounds
        refreshGraphLayer()
        // MOE - вызыва функции отписовки пути по точкам
    }
    
    //================  - (void)refreshGraphLayer   ======================================================
    func refreshGraphLayer() {
        if chartContainer.numberOfElements() == 0 {
            return
        }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: CGFloat(0.0)))
        let numberOfPoints: Int = chartContainer.numberOfElements()
        numberOfPreviousElements = numberOfPoints
        var xPosition: CGFloat = 0.0
        let yMargin: CGFloat = 0.0
        var yPosition: CGFloat = 0.0
        //[_graphLayer setStrokeColor:[[self.chartContainer lineColor] CGColor]];
        graphLayer?.strokeColor = UIColor.red.cgColor
        // MOE - вот реально цвет задается
        var lastPoint = CGPoint(x: CGFloat(0), y: CGFloat(0))
        CATransaction.begin()
        for i in 0..<numberOfPoints {
            //---- первый цикл -----------------
            let value: CGFloat = chartContainer.valueForElement(atRow: i)
            // MOE - вот тут берется value, с которого расчитывается Y-координата
            let minGridValue: CGFloat = chartContainer.minValue()
            // используется spacingForElementAtRow + minGridValue
            xPosition += chartContainer.spacingForElement(atRow: i)
            yPosition = yMargin + floor((value - minGridValue) * pixelToRecordPoint())
            let newPosition = CGPoint(x: xPosition, y: yPosition)
            path.addLine(to: newPosition)
            let circle: CALayer? = circleLayerForPoint(atRow: i)
            var oldPosition: CGPoint? = circle?.presentation()?.position
            oldPosition?.x = newPosition.x
            circle?.position = newPosition
            lastPoint = newPosition
            //animate position change
            if animationNeeded {
                let positionAnimation = CABasicAnimation(keyPath: "position")
                positionAnimation.duration = chartContainer.animationDuration()
                positionAnimation.fromValue = NSValue(oldPosition)
                positionAnimation.toValue = NSValue(newPosition)
                //[positionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                positionAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
                circle?.addAnimation(positionAnimation, forKey: "position")
            }
        }
        //---- первый цикл -----------------
        // hide other circles if needed
        //hide them under minValue - 10.0 points
        if graphLayer?.sublayers?.count > numberOfPoints {
            //------ тут не понятно, что делается ---------------------
            for i in numberOfPoints..<graphLayer?.sublayers?.count {
                let circle: CALayer? = circleLayerForPoint(atRow: i)
                let oldPosition: CGPoint? = circle?.presentation()?.position
                let newPosition = CGPoint(x: CGFloat(oldPosition?.x), y: CGFloat(chartContainer.minValue() - 50.0))
                circle?.position = newPosition
                // animate position change
                if animationNeeded {
                    let positionAnimation = CABasicAnimation(keyPath: "position")
                    positionAnimation.duration = chartContainer.animationDuration()
                    positionAnimation.fromValue = NSValue(oldPosition)
                    positionAnimation.toValue = NSValue(newPosition)
                    positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    circle?.addAnimation(positionAnimation, forKey: "position")
                }
            }
        }
        //------ тут не понятно, что делается ---------------------
        let oldPath: CGPathRef? = graphLayer?.presentation()?.path
        let newPath: CGPathRef = path.cgPath
        graphLayer?.path = path.cgPath
        if animationNeeded {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = chartContainer.animationDuration()
            pathAnimation.fromValue = (oldPath as? Any)
            pathAnimation.toValue = (newPath as? Any)
            pathAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
            graphLayer?.addAnimation(pathAnimation, forKey: "path")
        }
        let copyPath = UIBezierPath(CGPath: path.cgPath)
        copyPath.addLine(to: CGPoint(x: CGFloat(lastPoint.x + 90), y: CGFloat(-100)))
        //[copyPath addLineToPoint:CGPointMake(0.0, 0.0)];
        let maskOldPath: CGPathRef? = maskLayer?.presentation()?.path
        let maskNewPath: CGPathRef = copyPath.cgPath
        maskLayer?.path = copyPath.cgPath
        gradientLayer?.mask = maskLayer
        if animationNeeded {
            let pathAnimation2 = CABasicAnimation(keyPath: "path")
            pathAnimation2.duration = chartContainer.animationDuration()
            pathAnimation2.fromValue = (maskOldPath as? Any)
            pathAnimation2.toValue = (maskNewPath as? Any)
            //[pathAnimation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            pathAnimation2.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
            maskLayer?.addAnimation(pathAnimation2, forKey: "path")
        }
        CATransaction.commit()
    }
    
    //================ end  - (void)refreshGraphLayer   ===============================================
    // MARK: -
    // MARK: - Helpers
    func viewHeight() -> CGFloat {
        let font: UIFont? = chartContainer.gridIntervalFont()
        let maxHeight: CGFloat? = round(frame.height - font?.lineHeight)
        return maxHeight!
    }
    
    func pixelToRecordPoint() -> CGFloat {
        let maxHeight: CGFloat = viewHeight()
        let maxIntervalValue: CGFloat = chartContainer.maxValue()
        let minIntervalValue: CGFloat = chartContainer.minValue()
        return (maxHeight / (maxIntervalValue - minIntervalValue))
    }
    
    func circleLayerForPoint(atRow row: Int) -> CALayer {
        let totalNumberOfCircles: Int? = graphLayer?.sublayers?.count
        if row >= totalNumberOfCircles {
            let circleLayer: CALayer? = newCircleLayer()
            graphLayer?.addSublayer(circleLayer)
        }
        return graphLayer?.sublayers![row]!
    }
    
    func newCircleLayer() -> CALayer {
        let newCircleLayer = CALayer()
        let img: UIImage? = circleImage()
        newCircleLayer.contents = (img?.cgImage as? Any)
        newCircleLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(img?.size?.width), height: CGFloat(img?.size?.height))
        newCircleLayer.geometryFlipped = true
        return newCircleLayer
    }
    
    func circleImage() -> UIImage {
        if !_circleImage {
            let imageSize = CGSize(width: CGFloat(CIRCLE_SIZE), height: CGFloat(CIRCLE_SIZE))
            let strokeWidth: CGFloat = 2
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            //[UIImage imageNamed:@"circle"];
            let context: CGContext? = UIGraphicsGetCurrentContext()
            UIColor.clear.setFill()
            context.fill([CGPoint.zero, imageSize])
            let ovalPath = UIBezierPath(ovalin: (CGRect))
            context.saveGState()
            chartContainer.elementFillColor().setFill()
            ovalPath.fill()
            context.restoreGState()
            chartContainer.elementStrokeColor().setStroke()
            ovalPath.lineWidth = strokeWidth
            ovalPath.stroke()
            _circleImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return _circleImage
    }
    
    // MARK: -
    // MARK: - Autolayout code
    func intrinsicContentSize() -> CGSize {
        var width: CGFloat = 0.0
        let totalElements: Int = chartContainer.numberOfElements()
        for i in 0..<totalElements {
            width += chartContainer.spacingForElement(atRow: i)
        }
        width += circleImage().size.width
        if width < preferredMinLayoutWidth() {
            width = preferredMinLayoutWidth()
        }
        return CGSize(width: width, height: CGFloat(UIViewNoIntrinsicMetric))
    }
    
    func setPreferredMinLayoutWidth(_ preferredMinLayoutWidth: CGFloat) {
        if _preferredMinLayoutWidth != preferredMinLayoutWidth {
            _preferredMinLayoutWidth = preferredMinLayoutWidth
            if frame.width < preferredMinLayoutWidth {
                invalidateIntrinsicContentSize()
            }
        }
    }


}//------ end of class -----------------------------------------------------
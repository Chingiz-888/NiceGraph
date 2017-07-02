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
    // Support for constraint-based layout (auto layout)
    // If nonzero, this is used when determining -intrinsicContentSize
    var preferredMinLayoutWidth: CGFloat = 0.0
    
    let INTERVAL_TEXT_LEFT_MARGIN = 10.0
    let INTERVAL_TEXT_MAX_WIDTH   = 100.0
    let CIRCLE_SIZE : CGFloat     = 14.0
    
    
    private var graphLayer     : CAShapeLayer?
    private var maskLayer      : CAShapeLayer?
    private var gradientLayer  : CAGradientLayer?
    public var circleImage     : UIImage?
    private var numberOfPreviousElements: Int = 0
    private var maxValue       : CGFloat     = 0.0
    private var minValue       : CGFloat     = 0.0
    private var animationNeeded: Bool = false
    
    private var width          : CGFloat = 0.0
    
    
    //----- ДОБАВОЧНАЯ ЛОГИКА ОТ BEZIER GRAPH -----------
        var myPoints : [CGPoint]?
    //---------------------------------------------------
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, chartContainer: nil)
    }

    init(frame: CGRect, chartContainer: ANDLineChartView?) {
        super.init(frame: frame)
        
        self.chartContainer = chartContainer
        setupGradientLayer()
        setupMaskLayer()
        setupGraphLayer()
        backgroundColor     = UIColor.clear
        isOpaque            = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGraphLayer() {
        graphLayer = CAShapeLayer()
        graphLayer?.frame = bounds
        graphLayer?.isGeometryFlipped = true
        graphLayer?.strokeColor = chartContainer?.lineColor?.cgColor
        graphLayer?.fillColor = nil
        graphLayer?.lineWidth = 2.0
        graphLayer?.lineJoin = kCALineJoinBevel
        self.layer.addSublayer(graphLayer!)
    }
    
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
//        let color1: CGColor = UIColor(white: CGFloat(1.000), alpha: CGFloat(0.7)).cgColor
//        let color2: CGColor = UIColor(white: CGFloat(1.000), alpha: CGFloat(0.0)).cgColor
        

        var colors = [CGColor]();
        let increment : Float = 0.2;
        var hue : Float = 0.2
        while (hue<1.0)  {
            let color =  UIColor.init(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 0.7).cgColor
            colors.append(color)
            hue += increment
        }
        
        
        
        //gradientLayer?.colors = [(color1 as? Any), (color2 as? Any)]
        gradientLayer?.colors = colors
        
        gradientLayer?.locations = [0.0, 0.25, 0.5, 1.0]
        gradientLayer?.frame = bounds
        layer.addSublayer(gradientLayer!)
    }
    
    func setupMaskLayer() {
        maskLayer = CAShapeLayer()
        maskLayer?.frame = bounds
        maskLayer?.isGeometryFlipped = true
        maskLayer?.strokeColor = UIColor.clear.cgColor
        maskLayer?.fillColor = UIColor.black.cgColor
        maskLayer?.lineWidth = 2.0
        maskLayer?.lineJoin = kCALineJoinBevel
        maskLayer?.masksToBounds = true
    }
    
    func reloadData() {
        animationNeeded = true
        let numberOfPoints: Int = chartContainer!.numberOfElements()
        if numberOfPoints != numberOfPreviousElements {
            invalidateIntrinsicContentSize()
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        graphLayer?.frame    = self.bounds
        maskLayer?.frame     = self.bounds
        gradientLayer?.frame = self.bounds
        refreshGraphLayer()
        // MOE - вызыва функции отписовки пути по точкам
    }
    
    
    
    
    
    //**** НОВАЯ ЛОГИКА BEZIER GRAPH ******
    func getMyPoints() -> [CGPoint]? {
        let numberOfPoints: Int  = chartContainer!.numberOfElements()
        numberOfPreviousElements = numberOfPoints
        var xPosition: CGFloat   = 0.0
        var yPosition: CGFloat   = 0.0
        let yMargin  : CGFloat   = 0.0
        var lastPoint            = CGPoint(x: CGFloat(0), y: CGFloat(0))
        var points   : [CGPoint] = [CGPoint]()
        
        for i in 0..<numberOfPoints
        {//---- первый цикл ------------------------
            
            //---- вот так создается новая CGPoint - все от value valueForElement(atRow: i) -----
            // MOE - вот тут берется value, с которого расчитывается Y-координата
            // используется spacingForElementAtRow + minGridValue
            let value        : CGFloat = chartContainer!.valueForElement(atRow: i)
            let minGridValue : CGFloat = chartContainer!.minValue()
            xPosition                 += (chartContainer?.spacingForElement(atRow: i))!
            yPosition                  = yMargin + floor((value - minGridValue) * pixelToRecordPoint())   //pixelToRecordPoint - отношение max к min
            let newPosition            = CGPoint(x: xPosition, y: yPosition)
            //-----------------------------------------
            
            points.append(newPosition)
          
            
        }//---- конец первого цикла -----------------
        return points
    }
    //*************************************
    
    
    
    
    
    
    
    //====================================================================================================
    //====================================================================================================
    //MARK================ - (void)refreshGraphLayer   ===================================================
    func refreshGraphLayer() {
        if chartContainer?.numberOfElements() == 0 {
            return
        }
        var path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(0.0), y: CGFloat(0.0)))
        let numberOfPoints: Int  = chartContainer!.numberOfElements()
        numberOfPreviousElements = numberOfPoints
        var xPosition: CGFloat   = 0.0
        let yMargin:   CGFloat   = 0.0
        var yPosition: CGFloat   = 0.0
        graphLayer?.strokeColor = self.chartContainer?.lineColor?.cgColor //UIColor.red.cgColor // цвет линий
        var lastPoint = CGPoint(x: CGFloat(0), y: CGFloat(0))
        
        CATransaction.begin()
        
        
        
         //**** НОВАЯ ЛОГИКА BEZIER GRAPH ******
         myPoints = getMyPoints()
         guard let pointss = myPoints else {
            assert(false, "getMyPoints() функция сломалась")
            return
        }
        // ВОТ ОН МОЙ НОВЫЙ АЛГОРИТМ - и я сразу поулчаю PATH, а не массив controlPoint'ов (CubicSegment)
        // от которых мнеп отом еще надо самому чертить BezierPath
        // у нас есть массив [CGPoint] и мы в ответ на него получаем UIBezierPath
        
        let newAlgorithm = CubicCurvedPath(data: myPoints!)
        path = newAlgorithm.cubicCurvedPath()
        //************************************
        
        
        

        for i in 0..<numberOfPoints
        {//---- первый цикл ------------------------
           
            //---- вот так создается новая CGPoint - все от value valueForElement(atRow: i) -----
            // MOE - вот тут берется value, с которого расчитывается Y-координата
            // используется spacingForElementAtRow + minGridValue
            let value        : CGFloat = chartContainer!.valueForElement(atRow: i)
            let minGridValue : CGFloat = chartContainer!.minValue()
            
            xPosition      += (chartContainer?.spacingForElement(atRow: i))!
            yPosition       = yMargin + floor((value - minGridValue) * pixelToRecordPoint())   //pixelToRecordPoint - отношение max к min
            let newPosition = CGPoint(x: xPosition, y: yPosition)
            
               //**** НОВАЯ ЛОГИКА BEZIER GRAPH ******
                     let myPoint = newPosition
               //*************************************
            //-----------------------------------------
    
   
            let circle: CALayer? = circleLayerForPoint(atRow: i)
            var oldPosition: CGPoint? = circle?.presentation()?.position
            oldPosition?.x = newPosition.x
            circle?.position = newPosition
            lastPoint = newPosition
            //animate position change
            if animationNeeded {
                let positionAnimation = CABasicAnimation(keyPath: "position")
                positionAnimation.duration  = chartContainer!.animationDuration
                positionAnimation.fromValue = NSValue(cgPoint: oldPosition!)
                positionAnimation.toValue   = NSValue(cgPoint: newPosition)
                //[positionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                positionAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
                circle?.add(positionAnimation, forKey: "position")
            }
            
        }//---- конец первого цикла -----------------
        
        
        // hide other circles if needed
        //hide them under minValue - 10.0 points
//        if (graphLayer?.sublayers?.count)! > numberOfPoints {
//            //------ тут не понятно, что делается ---------------------
//            for i in numberOfPoints..<(graphLayer?.sublayers?.count)! {
//                let circle      : CALayer? = circleLayerForPoint(atRow: i)
//                let oldPosition : CGPoint? = circle?.presentation()?.position
//                let newPosition            = CGPoint(  x: CGFloat((oldPosition?.x)!),
//                                                       y: CGFloat( (chartContainer?.minValue())! - 50.0 )  )
//                circle?.position           = newPosition
//                // animate position change
//                if animationNeeded {
//                    let positionAnimation            = CABasicAnimation(keyPath: "position")
//                    positionAnimation.duration       = chartContainer!.animationDuration
//                    positionAnimation.fromValue      = NSValue(cgPoint: oldPosition!)
//                    positionAnimation.toValue        = NSValue(cgPoint: newPosition)
//                    positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                    circle?.add(positionAnimation, forKey: "position")
//                }
//            }
//        }
        //------ тут не понятно, что делается ---------------------
        let oldPath: CGPath? = graphLayer?.presentation()?.path
        let newPath: CGPath  = path.cgPath
        graphLayer?.path     = path.cgPath
        if animationNeeded {
            let pathAnimation             = CABasicAnimation(keyPath: "path")
            pathAnimation.duration        = chartContainer!.animationDuration
            pathAnimation.fromValue       = (oldPath as? Any)
            pathAnimation.toValue         = (newPath as? Any)
            pathAnimation.timingFunction  = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
            graphLayer?.add(pathAnimation, forKey: "path")
        }
        let copyPath = UIBezierPath(cgPath: path.cgPath)
        
        // завершение path'а - я обратил внимание, что к верху надо, а не к низу
        copyPath.addLine(to: CGPoint(x: CGFloat(lastPoint.x + 90), y: CGFloat(-300)))
        copyPath.addLine(to: CGPoint(x: CGFloat(0), y: CGFloat(-300)))
        copyPath.addLine(to: CGPoint(x: CGFloat(0), y: CGFloat( pointss[0].y  )))
        
        //[copyPath addLineToPoint:CGPointMake(0.0, 0.0)];
        let maskOldPath: CGPath?          = maskLayer?.presentation()?.path
        let maskNewPath: CGPath           = copyPath.cgPath
        maskLayer?.path                   = copyPath.cgPath
        gradientLayer?.mask               = maskLayer
        if animationNeeded {
            let pathAnimation2            = CABasicAnimation(keyPath: "path")
            pathAnimation2.duration       = chartContainer!.animationDuration
            pathAnimation2.fromValue      = (maskOldPath as? Any)
            pathAnimation2.toValue        = (maskNewPath as? Any)
            //[pathAnimation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            pathAnimation2.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.4, 1, 1)
            maskLayer?.add(pathAnimation2, forKey: "path")
        }
        CATransaction.commit()
    }//====================================================================================================
     //====================================================================================================
     //====================================================================================================
    
    
    
    
    
    
    
    
    
    
    //================ end  - (void)refreshGraphLayer   ===============================================
    // MARK: -
    // MARK: - Helpers
    func viewHeight() -> CGFloat {
        let font: UIFont?       = chartContainer?.gridIntervalFont
        //print("\(frame.height) - \(font?.lineHeight)")   // portrait 676.0 - 13.98   и landscape 374.0 - 13.98
        let maxHeight: CGFloat? = round(frame.height - (font?.lineHeight)!)  //662 и 360
        return maxHeight!
    }
    
    func pixelToRecordPoint() -> CGFloat {
        let maxHeight: CGFloat = viewHeight()     // максимальная высотка frame'а за вычетом размера шоифта
        let maxIntervalValue: CGFloat = chartContainer!.maxValue()
        let minIntervalValue: CGFloat = chartContainer!.minValue()
        return (maxHeight / (maxIntervalValue - minIntervalValue))
    }
    
    
    //  // MOE
    // Вот тут пришшлось понять логику и переписать функцию
    // суть тут в том, что в 2 условиях создаются и присобачиваются сабслои - когда вообше нет еще саблойеров graphLayer?.sublayers?.count  == nil
    // и когда запрошенный row превосходит graphLayer?.sublayers?.count
    
    func circleLayerForPoint(atRow row: Int) -> CALayer {
        if let totalNumberOfCircles: Int? = graphLayer?.sublayers?.count {
            if(row < totalNumberOfCircles!) {
                 return (graphLayer?.sublayers?[row])!
            } else {
                let circleLayer: CALayer? = newCircleLayer()
                graphLayer?.addSublayer(circleLayer!)
                return (graphLayer?.sublayers?[row])!
            }
        } else {
            let circleLayer: CALayer? = newCircleLayer()
            graphLayer?.addSublayer(circleLayer!)
            return (graphLayer?.sublayers?[row])!
        }
    }
    
    func newCircleLayer() -> CALayer {
        let newCircleLayer = CALayer()
        let img: UIImage? = getCircleImage()
        newCircleLayer.contents = (img?.cgImage as? Any)
        newCircleLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((img?.size.width)!), height: CGFloat((img?.size.height)!))
        newCircleLayer.isGeometryFlipped = true
        return newCircleLayer
    }
    
    func getCircleImage() -> UIImage {
        if circleImage == nil {
            let imageSize = CGSize(width: CGFloat(CIRCLE_SIZE), height: CGFloat(CIRCLE_SIZE))
            let strokeWidth: CGFloat = 2.0
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            //[UIImage imageNamed:@"circle"];
            let context = UIGraphicsGetCurrentContext()
            UIColor.clear.setFill()
            
            context?.fill( CGRect.init(origin: CGPoint.zero, size: imageSize) )      // fill([CGPoint.zero, imageSize])
            let ss = CIRCLE_SIZE - strokeWidth
            let ovalPath = UIBezierPath.init(ovalIn: CGRect.init(origin: CGPoint(x: strokeWidth/2.0, y: strokeWidth/2.0),
                                                                  size: CGSize(width: ss, height:  ss)))
            
            
            context?.saveGState()
            chartContainer?.elementFillColor?.setFill()
            ovalPath.fill()
            context?.restoreGState()
            chartContainer?.elementStrokeColor?.setStroke()
            ovalPath.lineWidth = strokeWidth
            ovalPath.stroke()
            circleImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return circleImage!
    }
    
    // MARK: -
    // MARK: - Autolayout code
    
    //MOE - НАДО РАЗОБРАТЬСЯ, ЗАЕМ НУЖНО БЫЛО УЗНАВАТЬ И ДОБАЛВТЬЯ ЕШЕ РАЗМЕР ШАРОВ ===============================================
    override public var intrinsicContentSize: CGSize {
   
        width  = 0.0
        let totalElements: Int = chartContainer!.numberOfElements()
        for i in 0..<totalElements {
            width += (chartContainer?.spacingForElement(atRow: i))!
        }
       // width += (circleImage?.size.width)!
        width += getCircleImage().size.width
        
        if width < preferredMinLayoutWidth {
            width = preferredMinLayoutWidth
        }
        return CGSize(width: width, height: CGFloat(UIViewNoIntrinsicMetric))
    }
    
    //func setPreferredMinLayoutWidth(_ preferredMinLayoutWidth: CGFloat) {
    func setPreferredMinLayoutWidth(preferredMinLayoutWidth: CGFloat) {
        if preferredMinLayoutWidth != preferredMinLayoutWidth {
            self.preferredMinLayoutWidth = preferredMinLayoutWidth
            if frame.width < preferredMinLayoutWidth {
                invalidateIntrinsicContentSize()
            }
        }
    }


}//------ end of class -----------------------------------------------------

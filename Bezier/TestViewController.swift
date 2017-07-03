//
//  TestViewController.swift
//  Bezier
//
//  Created by Чингиз Б on 28.06.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit



// Наша модель данных
struct DataSet {
    var timestamp: Int
    var value : Float
    var date : String?
    
    init (timestamp: Int, value: Float) {
        self.timestamp  = timestamp
        self.value = value
    }
}





class TestViewController: UIViewController {

    
    @IBOutlet weak var viewForChart: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var whiteView: UIView!
    
    
    // Наш массив с данными (распарсенными из сетевого JSON'а)
    var dataSets : [DataSet] = []
    // Наше регулярное выражение по выцеплению именно таймстемпа
    let patternForTimeStamp = "^[\\d]*"
    
    
    var MAX_NUMBER_COUNT     = Int()
    var MAX_NUMBER           = Int() {
        didSet {
            EXTRA_TO_MAX_NUMBER = Int(round((Float(self.MAX_NUMBER) * 0.15)))
        }
    }
    var MIN_NUMBER           = Int()
    var EXTRA_TO_MAX_NUMBER = Int()
    var _elements : [Int] = [Int]()
    var _chartView : ANDLineChartView?
    var _maxValue     : Int  = Int()
    var _numbersCount : Int  = Int()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        MAX_NUMBER_COUNT = 888
//        MAX_NUMBER = 20
//     
//        _maxValue     = self.MAX_NUMBER
//        _numbersCount = self.MAX_NUMBER_COUNT;
//        _chartView = ANDLineChartView(frame: CGRect.zero)
//        _chartView?.translatesAutoresizingMaskIntoConstraints = false
//        _chartView?.dataSource        = self
//        _chartView?.delegate          = self
//        _chartView?.animationDuration = 0.4
//        
//        // ВАРИАНТ 1 - chartView добавляется прямо на superview - self.view
//        // self.view.addSubview(_chartView!)
//        
//        // ВАРИАНТ 2 - chartView добавляется на view-подложку
//        self.viewForChart.addSubview(_chartView!)
//        
//        _elements = self.arrayWithRandomNumbers()
//        self.setupConstraints()
        getData()
    }

    @IBAction func reloadData(_ sender: Any) {
        getData()
    }

    
    func getData() {
        
        whiteView.alpha = 1.0
        whiteView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        whiteView.backgroundColor = UIColor.white
        
        _chartView?.removeFromSuperview()
        self.view.layoutIfNeeded()
        
        // тестовый набор данных
        // https://xn----9sbb2ac5bgif6fd.xn--p1ai/test_bezier_data.json
        
        
        // обнуляем данные
        self.dataSets = []
        
        let jsonUrl = NSURL(string: "https://xn----9sbb2ac5bgif6fd.xn--p1ai/test_bezier_data.json")!
        let jsonUrlRequest = NSMutableURLRequest(url: jsonUrl as URL)
        jsonUrlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: jsonUrlRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            //let jsonSample = String(data: data!, encoding: String.Encoding.utf8)
            //print(jsonSample)
            
                guard let data = data else {
                    print("Ошибка в ответе сервера \(error)")
                    return
                }
            
                // пробуем распарсить
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: String]] {
                        // проходимся циклом
                        for i in 0..<jsonArray.count{
                            if let jsonDict = jsonArray[i] as? [String : String] {
                         
                                let timeStampString = matches(for: self.patternForTimeStamp, in: jsonDict["date"]!)
                                let timeStamp = Int(timeStampString[0]) ?? 0
                                let value = Float(jsonDict["value"]!) ?? 0.0
                                self.dataSets.append( DataSet(timestamp: timeStamp, value: value ) )
                            }
                        }
                        // Запускаем отрисовку графика
                        self.getDatesAndDrawGraph()
                    }
                } catch let parseError {
                    print("parsing error: \(parseError)")
                    let responseString = String(data: data, encoding: .utf8)
                    print("raw response: \(responseString)")
                }
        }.resume()
        
    }// --- end of func getData() ---------------
    
    
    func getDatesAndDrawGraph() {
        
        // сначала переводим таймстемпы в обычные даты
        for i in 0..<self.dataSets.count {
            let date = NSDate(timeIntervalSince1970: TimeInterval(self.dataSets[i].timestamp) )
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "d MMMM, hh:mm"
            let dateString = dayTimePeriodFormatter.string(from: date as Date)
            self.dataSets[i].date = dateString
            //print( " _ts value is \(dateString)")
        }
        
        
        var max : Float = -10.0
        for i in 0..<self.dataSets.count {
            if i == 0 {
                max = self.dataSets[i].value
            } else {
                if max < self.dataSets[i].value {
                    max = self.dataSets[i].value
                }
            }
        }
        
        var min : Float = 10000.0
        for i in 0..<self.dataSets.count {
            if i == 0 {
                min = self.dataSets[i].value
            } else {
                if min > self.dataSets[i].value {
                    min = self.dataSets[i].value
                }
            }
        }
        
        
        
        MAX_NUMBER_COUNT = self.dataSets.count
        MAX_NUMBER = Int(max)
        MIN_NUMBER = Int(min)
        
        _maxValue     = self.MAX_NUMBER
        _numbersCount = self.MAX_NUMBER_COUNT;
        _chartView = ANDLineChartView(frame: CGRect.zero)
        _chartView?.translatesAutoresizingMaskIntoConstraints = false
        _chartView?.dataSource        = self
        _chartView?.delegate          = self
        _chartView?.animationDuration = 0.4
        
        // ВАРИАНТ 2 - chartView добавляется на view-подложку
        self.viewForChart.addSubview(_chartView!)
        self.setupConstraints()
        
        
        //убираем заглушку и активити индикатор
        
        whiteView.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
//        UIView.animate(withDuration: 2.0, animations: {
//            self.whiteView.alpha = 0.0
//        }, completion: { Void in
//            self.whiteView.isHidden = true
//        })
        
        UIView.animate(withDuration: 2, delay: 1, options: .curveEaseIn, animations: {
            self.whiteView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            self.whiteView.isHidden = true
        }
        
    }
    
    
    // у нас данные тянуться уже с сети, потому не нужна эта заглушка
    func arrayWithRandomNumbers() -> [Int] {
        var random = [Int]()
        for i in 0..<_numbersCount {
            var r : UInt = UInt(arc4random_uniform( UInt32(_maxValue + 1)   )   )
            random.append(Int(r))
        }
        return random
    }
    
    
    
    
    func setupConstraints() {
       
        // ВАРИАНТ 1 - chartView добавляется прямо на superview - self.view
        /*let topLayoutGuide =  self.topLayoutGuide
        let views: [String: AnyObject] = ["_chartView"    : _chartView!,
                                          "topLayoutGuide": topLayoutGuide]*/
        //let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-20-[_chartView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        //let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[_chartView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        // self.view.addConstraints(constraints1)
        // self.view.addConstraints(constraints2)
        
        
        // ВАРИАНТ 2 - chartView добавляется на view-подложку
        let views: [String: AnyObject] = [ "viewForChart"  : viewForChart,
                                           "_chartView"    : _chartView! ]
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-10)-[_chartView]-(-10)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-10)-[_chartView]-(-10)-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        self.viewForChart.addConstraints(constraints1)
        self.viewForChart.addConstraints(constraints2)
       
    }
}//----- end of class declaration -----------------






func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}












// MARK:   Methods of ANDLineChartViewDataSource protoocol ----------------------------
extension TestViewController : ANDLineChartViewDataSource {
    func chartView(_ chartView: ANDLineChartView, dateForElementAtRow row: Int) -> String? {
        return self.dataSets[row].date ?? "нет данных"
    }
    
    func chartView(_ chartView: ANDLineChartView, valueForElementAtRow row: Int) -> CGFloat? {
        return CGFloat( self.dataSets[row].value )
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
        return  CGFloat(MIN_NUMBER) - CGFloat(self.EXTRA_TO_MAX_NUMBER)*1.12              //!!! снизу езе убираем, чтобы были видны подпсии к датам
    }
}//--------------------------------------------------------------------------------------


// MARK:   Methods of ANDLineChartViewDelegate protoocol ----------------------------
extension TestViewController : ANDLineChartViewDelegate {
    func chartView(_ chartView: ANDLineChartView, spacingForElementAtRow row: Int) -> CGFloat {
       return (row == 0) ? 60.0 : 30.0
    }
}




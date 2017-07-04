  ##Построение плавного графика на основе массива [Float] значений, получаемых извне в JSON-формате. Написано на Swift 3.1
  ##Drawing a nice smooth bezier curve through a parsed from JSON array of [Float] points - written in Swift 3.1.
 
  Адаптировано по новейший XCode 8.3.3 и Swift 3.1

  1) График строится на основе ANDLineChartView  [https://github.com/anaglik/ANDLineChartView](https://github.com/anaglik/ANDLineChartView) (Objective C проект) и
             [https://github.com/johnyorke/JYGraphView](https://github.com/johnyorke/JYGraphView)
  2) Были сделаны изменения в логике просчета кубических кривых Безье, дабы они не выходили за границы точек, если данная точка
     самая высокая или низкая по сравнению со своими соседями слева и справа (стандартный алгоритм
         https://medium.com/@ramshandilya/draw-smooth-curves-through-a-set-of-points-in-ios-34f6d73c8f9   этим как раз-таки и грешил
      Как это можно было сделать помогла вот эта тема - https://stackoverflow.com/questions/13719143/draw-graph-curves-with-uibezierpath
      Что в итоге получилось, смотрте в CubicCurvePath.swift
  3) График можно встроить в проект обычным включением 4 файлов, содержащихся в папке ANDLineChart, никаких pod'ов не требуется
  4) График можно включить в ViewController 2 способами - прямым добавлением на superview или на UIView-подлжоку (вариант 2)
      И в том и в другом случае необходимо задание 2 constraints - они в данном файле уже прописаны
  5) Внешний вид графика задается ANDLineChartViewDataSource и ANDLineChartViewDelegate функциями
  6) Также, показывать или нет ось ординат (Y-ось) и отметки там задается в ANDLineChartView в функции setupDefaultAppearence()
  7) Отментки на оси абсцисс (X-ось) и покрытие или нет его градиентной заливкой задается в ANDLineInternalLineChartView.swift
    в функции layoutSubviews()  и в setupLabels()
  8) Название графика задается в ANDLineChartView.swift в функции setupGraphTitle()
  9) Внимательный читатель может заметить использование переменной EXTRA_TO_MAX_NUMBER. Она нужна для того, чтобы было место для вехней надписи графика и
      нижний отметок на оси X
  10) На случай работы с серверами, работающими по протоколу http в файл Info.plist включено соответствующее разрещающее правило
          <key>NSAppTransportSecurity</key>
          <dict>
                <key>NSAllowsArbitraryLoads</key>
                 <true/>
         </dict>
     А то можно нарваться на ошибку Error Domain=NSURLErrorDomain Code=-1022 
      "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."
 11) ВНИМАНИЕ, парсинг JSON настроен на вот такой формат:  [{"date":"506948248.665283","value":"-23.9"},{"date":"507034648.665283","value":"40.3"}...]
     Таймстемп можно передавать и без микросекунд, то есть просто "date":"506948248" ибо сейчас программа все равно регулярынм выражением берет
     только первый блок цифр
 12) URL адрес откуда тянется JSON задается в константе urlJson


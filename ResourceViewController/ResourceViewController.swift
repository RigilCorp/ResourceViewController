//
//  ViewController.swift
//  ResourcesViewController
//
//  Created by Yishak Abraham on 6/3/16.
//  Copyright © 2016 RigilCorp. All rights reserved.
//

import UIKit

protocol ResourceLinksDataSource {
    //Links View
    func resourceViewControllerNumberOfLinkSections(viewController: ResourceViewController) -> Int
    func resourceViewController(viewController: ResourceViewController, numberOfRowsForLinkSection: Int) -> Int
    func resourceViewController(viewController: ResourceViewController, collectionView: UICollectionView, cellForLinkAtPath indexPath: IndexPath) -> UICollectionViewCell
    func resourceViewController(viewController: ResourceViewController, tableView: UITableView, cellForLinkAtPath indexPath: IndexPath) -> UITableViewCell
    func resourceViewController(viewController: ResourceViewController, didSelectPath indexPath: IndexPath)
}

class ResourceViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, RCChartViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    

    private var pageScrollView: UIScrollView?
    
    private var pageControl: UIPageControl?
    private var pages = [UIView]()
    
    //Bar chart view and properties
    private var barChartPageView : UIView?
    private var yAxisLabelsContainerView : UIView?
    private var chart : RCChartView?
    private var legendTableView : UITableView?
    private var totalValues : [CGFloat]?
    private var totalTitles : [String]?
    private var chartColors : [UIColor]?
    let maskLayer = CAGradientLayer()
    private var gradientView : UIView?
    private let defaultColors = [UIColor(red: 90.0/255.0, green: 200.0/255.0, blue: 250/255.0, alpha: 1.0),
                                 UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 0/255.0, alpha: 1.0),
                                 UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0),
                                 UIColor(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0),
                                 UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                                 UIColor(red: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0),
                                 UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
    
    //Properties view and properties
    private var propertiesPageView : UIView?
    private var propertiesTableView : UITableView?
    private var propertyTitles : [String]?
    private var propertyValues : [String]?
    
    //Links view and properties
    private var linksPageView: UIView?
    private var linksTableView: UITableView?
    private var linkTitles: [String]?
    private var linkDescriptions: [String]?
    private var isLinksGridMode = false
    private var linksCollectionView: UICollectionView?
    private var linksFlowLayout = UICollectionViewFlowLayout()
    var linksDataSource: ResourceLinksDataSource?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        //Set up scrollView
        pageScrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height - 30.0))
        self.view.addSubview(pageScrollView!)
        pageScrollView!.isPagingEnabled = true
        pageScrollView!.autoresizingMask = [.flexibleWidth,  .flexibleHeight]
        pageScrollView!.delegate = self
        pageScrollView?.canCancelContentTouches = false
        
        pageControl = UIPageControl(frame: CGRect(x: 0.0, y: self.view.frame.height - 30.0, width: 50.0, height: 30.0))
        pageControl?.center = CGPoint(x: self.view.frame.width / 2.0, y: pageControl!.center.y)
        pageControl?.currentPageIndicatorTintColor = UIColor.black
        pageControl?.pageIndicatorTintColor = UIColor.lightGray
        pageControl?.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
        self.view.addSubview(pageControl!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var barHeight: CGFloat = 0.0
        if let bar = self.navigationController?.navigationBar {
            barHeight = barHeight + bar.frame.height
        }
        barHeight = barHeight + UIApplication.shared.statusBarFrame.size.height
        pageScrollView!.contentSize = CGSize(width: pageScrollView!.frame.width * CGFloat(pages.count), height: pageScrollView!.frame.height-barHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.adjustForSize(size: size)
        
        coordinator.animate(alongsideTransition: nil) { (context) in
            //sometimes have to readjust if the size is different after transition,
            //than what was expected
            if self.view.frame.size != size {
                self.adjustForSize(size: self.view.frame.size)
            }
        }
    }
    
    func adjustForSize(size: CGSize) {
        pageScrollView!.contentSize = CGSize(width: size.width*3.0, height: size.height-30.0)
        
        if size.width >= size.height {
            //setup for landscape
            var y = (size.height-30.0) - (size.height-30.0) / 3.0 * 2.0 - 100.0
            y = (y < 20) ? 20.0 : y
            self.chart?.frame = CGRect(x: 80.0, y: y, width: (size.width)/3.0*2.0 - 100.0, height: (size.height-30.0) / 3.0 * 2.0)
            self.legendTableView?.frame = CGRect(x: self.chart!.frame.maxX, y: 20.0, width: size.width/3.0-25.0, height: self.chart!.frame.height/3.0*2.0)
            
        } else {
            //setup for portrait
            var y = (size.height-30.0) / 2.0 - 70.0
            y =  (y < (size.height-30.0)/3.0 + 20.0) ? (size.height-30.0)/3.0 + 20.0 : y
            self.chart?.frame = CGRect(x: 80.0, y: y, width: size.width-120.0, height: ((size.height-30.0) / 2.0) - 70.0)
            self.legendTableView?.frame = CGRect(x: 80.0, y: 20.0, width: size.width-120.0, height: (size.height-30.0)/3.0)
            
        }
        let xLabelHeight = chart!.frame.width / CGFloat(totalTitles!.count) - 8.0
        chart!.titlesHeight = xLabelHeight
        chart!.titlesFont = UIFont.systemFont(ofSize: 10.0 + chart!.frame.width/100.0)
        self.yAxisLabelsContainerView!.frame = CGRect(x: 0.0, y: (self.chart?.frame.minY)!, width: 80.0, height: (self.chart?.frame.height)!)
        
        self.gradientView?.frame = self.legendTableView!.frame
        self.maskLayer.frame = gradientView!.bounds
        chart?.reloadData()
        
        if isLinksGridMode {
            let numWide = floor(size.width/300)
            let cellWidth = size.width/numWide - 10.0
            linksFlowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
            linksFlowLayout.sectionInset = UIEdgeInsetsMake(10.0, 5.0, 5.0, 5.0)
            linksFlowLayout.minimumInteritemSpacing = 5.0
            linksFlowLayout.headerReferenceSize = CGSize(width: size.width, height: 44.0)
            linksFlowLayout.minimumLineSpacing = 5.0
            linksCollectionView?.reloadData()
        }
        
        pageScrollView?.setContentOffset(CGPoint(x: CGFloat(pageControl!.currentPage) * size.width, y: 0), animated: true)
    }
    
    //MARK: - Public
    func setup(totals: [String: AnyObject]?, properties: [String: AnyObject]?, links: [String: AnyObject]?, colors: [UIColor]?) {
        
        //Setup Totals bar chart page
        if totals != nil {
            self.setupTotalsPage(totals: totals!, colors: colors)
        }
        
        //Setup properties table
        if properties != nil {
            self.setupPropertiesPage(properties: properties!)
        }
        
        //Setup links page
        if links != nil {
            self.setupLinksPage(links: links!)
        }
        
        var barHeight: CGFloat = 0.0
        if let bar = self.navigationController?.navigationBar {
            barHeight = barHeight + bar.frame.height
        }
        barHeight = barHeight + UIApplication.shared.statusBarFrame.size.height
        pageScrollView!.contentSize = CGSize(width: (pageScrollView?.frame.width)! * CGFloat(pages.count), height: (pageScrollView?.frame.height)!-barHeight)
        
        if pages.count > 1 {
            pageControl?.numberOfPages = pages.count
            pageControl?.currentPage = 0
        } else {
            pageControl?.numberOfPages = 0
        }
        
    }
    
    func setup(totals: [String: AnyObject]?, properties: [String: AnyObject]?, linksDelegate: ResourceLinksDataSource, colors: [UIColor]?) {
        //Setup Totals bar chart page
        if totals != nil {
            self.setupTotalsPage(totals: totals!, colors: colors)
        }
        
        //Setup properties table
        if properties != nil {
            self.setupPropertiesPage(properties: properties!)
        }
        
        //Setup links page
        self.setupLinksPage(links: [String: AnyObject]())
        
        var barHeight: CGFloat = 0.0
        if let bar = self.navigationController?.navigationBar {
            barHeight = barHeight + bar.frame.height
        }
        barHeight = barHeight + UIApplication.shared.statusBarFrame.size.height
        pageScrollView!.contentSize = CGSize(width: (pageScrollView?.frame.width)! * CGFloat(pages.count), height: (pageScrollView?.frame.height)!-barHeight)
        
        if pages.count > 1 {
            pageControl?.numberOfPages = pages.count
            pageControl?.currentPage = 0
        } else {
            pageControl?.numberOfPages = 0
        }
    }
    
    func toggleLinksDisplay() {
        isLinksGridMode = !isLinksGridMode
        
        if isLinksGridMode {
            
            let numWide = floor(pageScrollView!.frame.width/300)
            let cellWidth = pageScrollView!.frame.width/numWide - 10.0
            linksFlowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
            linksFlowLayout.sectionInset = UIEdgeInsetsMake(10.0, 5.0, 5.0, 5.0)
            linksFlowLayout.minimumInteritemSpacing = 5.0
            linksFlowLayout.headerReferenceSize = CGSize(width: pageScrollView!.frame.width, height: 44.0)
            linksFlowLayout.minimumLineSpacing = 5.0
            
            if linksCollectionView != nil {
                linksCollectionView!.isHidden = false
                linksTableView!.isHidden = true
                
            } else {
                
                linksCollectionView = UICollectionView(frame: linksTableView!.frame, collectionViewLayout: linksFlowLayout)
                linksCollectionView?.backgroundColor = UIColor.white
                linksCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "LinkCell")
                linksCollectionView!.dataSource = self
                linksCollectionView!.delegate = self
                linksCollectionView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                linksPageView!.addSubview(linksCollectionView!)
            }
            
        }
    }
    
    //MARK: - Private
    
    private func setupTotalsPage(totals: [String: AnyObject], colors: [UIColor]?) {
        //Set colors for totals chart
        chartColors = defaultColors
        if colors != nil {
            if colors!.count > 0 {
                chartColors = colors!
            }
        }
        
        //Get the totals values
        totalTitles = Array(totals.keys)
        for title in totalTitles! {
            if totalValues == nil {
                totalValues = [CGFloat(totals[title] as! NSNumber)]
            } else {
                totalValues?.append(CGFloat(totals[title] as! NSNumber))
            }
        }
        
        if barChartPageView != nil {
            barChartPageView!.frame = CGRect(x: 0.0, y: 0.0, width: (pageScrollView?.frame.width)!, height: (pageScrollView?.frame.height)!)
            barChartPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleWidth, .flexibleHeight]
            
        } else {
            //Create and add the barchartPageView to the scrollview which is going to be on the first page
            barChartPageView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: pageScrollView!.frame.width, height: pageScrollView!.frame.height))
            barChartPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleWidth, .flexibleHeight]
            legendTableView = UITableView(frame: CGRect(x: (self.view.frame.maxX * 3.0/4.0) - 20.0, y: 100.0, width: self.view.frame.maxX / 4.0, height: self.view.frame.maxY), style:.grouped)
            
            pageScrollView!.addSubview(barChartPageView!)
        }
        pages.append(barChartPageView!)
        
        //Create and setup chart
        self.createChart(titles: totalTitles!, values: totalValues!, colors: defaultColors)
        
        //Create and legend table
        self.createLegendView(titles: totalTitles!, values: totalValues!, colors: defaultColors)
    }
    
    private func setupPropertiesPage(properties: [String: AnyObject]) {
        //Setup Properties values
        propertyTitles = Array(properties.keys)
        for proTitle in propertyTitles! {
            if propertyValues == nil {
                propertyValues = [properties[proTitle] as! String]
            } else {
                propertyValues?.append(properties[proTitle] as! String)
            }
        }
        
        if propertiesPageView != nil {
            propertiesPageView!.frame = CGRect(x: (pageScrollView?.frame.width)! * CGFloat(pages.count), y: 0.0, width: (pageScrollView?.frame.width)!, height: (pageScrollView?.frame.height)!)
            propertiesPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
            
        } else {
            //Create and add the propertiesPageView to the scrollview which is going to be on the second page
//            CGRect(x: (pageScrollView.frame.width) * CGFloat(pages.count), y: 0.0, width: pageScrollView.frame.width, height: pageScrollView?.frame.height)
            propertiesPageView = UIView(frame: CGRect(x: (pageScrollView?.frame.width)! * CGFloat(pages.count), y: 0.0, width: (pageScrollView?.frame.width)!, height: (pageScrollView?.frame.height)!))
            
            propertiesPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
            propertiesTableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: (propertiesPageView?.frame.width)!, height: (propertiesPageView?.frame.height)!), style: UITableViewStyle.plain)
            propertiesTableView?.dataSource = self
            propertiesTableView?.delegate = self
            propertiesTableView?.cellLayoutMarginsFollowReadableWidth = false
            propertiesTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            //Add propertiesTableView to propertiesPageView
            propertiesPageView!.addSubview(propertiesTableView!)
            
            //Add propertiesPageView to pageScrollView so that it is place on the second page
            pageScrollView!.addSubview(propertiesPageView!)
        }
        pages.append(propertiesPageView!)
        
    }
    
    private func setupLinksPage(links: [String: AnyObject]) {
        //Setup Links values
        linkTitles = Array(links.keys)
        for linkTitle in linkTitles! {
            
            if linkDescriptions == nil {
                linkDescriptions = [links[linkTitle] as! String]
                
            } else {
                linkDescriptions?.append(links[linkTitle] as! String)
            }
        }
        
        if linksPageView != nil {
            
            linksPageView!.frame = CGRect(x: 0.0, y: 0.0, width: (propertiesPageView?.frame.width)!, height: (propertiesPageView?.frame.height)!)
            linksPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
            
        } else {
            //Create and add the linksPageView to the scrollview which is going to be on the third page
            
            linksPageView = UIView(frame: CGRect(x: (pageScrollView?.frame.width)! * CGFloat(pages.count), y: 0.0, width: (pageScrollView?.frame.width)!, height: (pageScrollView?.frame.height)!))
            linksPageView!.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
            linksTableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: (linksPageView?.frame.width)!, height: (linksPageView?.frame.height)!), style: .plain)
            linksTableView!.dataSource = self
            linksTableView!.delegate = self
            linksTableView!.cellLayoutMarginsFollowReadableWidth = false
            linksTableView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            //Add linkTableView to linkPageView
            linksPageView!.addSubview(linksTableView!)
            
            //Add linkPageView to pageScrollView so that it is place on the second page
            pageScrollView!.addSubview(linksPageView!)
        }
        pages.append(linksPageView!)
        
    }
    
    private func createChart(titles: [String], values:[CGFloat], colors:[UIColor]) {
        
        //Remove any previous chart views
        chart?.removeFromSuperview()
        yAxisLabelsContainerView?.removeFromSuperview()
        
        //Sort Values to find the highest value to create labels
        let sortedValues = (values as NSArray).sorted { (first, second) -> Bool in
            if first as! CGFloat > second as! CGFloat {
                return true
            } else {
                return false
            }
        }
        
        if self.view.frame.size.width >= self.view.frame.size.height {
            //setup for landscape
            var y = barChartPageView!.frame.height - (barChartPageView!.frame.height) / 3.0 * 2.0 - 100.0
            y = (y < 20) ? 20.0 : y
            
            chart = RCChartView(frame: CGRect(x: 80.0, y: y, width: (pageScrollView?.frame.width)!/3.0*2.0 - 100.0, height: (barChartPageView?.frame.height)! * 2.0 / 3.0), style: RCChartStyleBar)
            
        } else {
            //setup for portrait
            chart = RCChartView(frame: CGRect(x: 80.0, y: ((pageScrollView?.frame.height)! / 2.0) - 70.0 , width:(pageScrollView?.frame.width)! - 120.0, height: ((pageScrollView?.frame.height)! / 2.0) - 70.0), style:RCChartStyleBar)
            
        }
        
  
        let sortedValuesN = NSMutableArray()
        
        for myFloat in sortedValues
        {
            let myNumber = NSNumber(value: Float(myFloat as! NSNumber))
            sortedValuesN.add(myNumber)
        }
        
        
        yAxisLabelsContainerView = self.chart!.createYAxisLabelsView(sortedValuesN as [AnyObject])
        
        barChartPageView?.addSubview(yAxisLabelsContainerView!)

        //Setup Chart subviews
        chart!.titlesColor = UIColor.darkText
        let xLabelHeight = chart!.frame.width / CGFloat(totalTitles!.count) - 8.0
        chart!.titlesHeight = xLabelHeight
        chart!.titlesFont = UIFont.systemFont(ofSize: 10.0 + chart!.frame.width/100.0)
        chart?.titleTextAlignment = NSTextAlignment.left
        chart!.displayTitles = true
        chart!.isUserInteractionEnabled = true
        chart!.dataSource = self
        
        barChartPageView!.addSubview(chart!)
        chart!.reloadData()
        
    }
    
    private func createLegendView(titles: [String], values:[CGFloat], colors:[UIColor]) {
        
        //Remove any previous legend views
        legendTableView?.removeFromSuperview()
        gradientView?.removeFromSuperview()
        
        //Setup LegendTableView based on device type and orientation
        if self.view.frame.size.width >= self.view.frame.size.height {
            //setup for landscape
            
            self.legendTableView = UITableView(frame: CGRect(x: (self.chart?.frame.maxX)!, y: 20.0, width: barChartPageView!.frame.width/3.0-25.0, height: self.chart!.frame.height/3.0*2.0), style: .plain)
            
        } else {
            //setup for portrait
            
            self.legendTableView = UITableView(frame: CGRect(x: 80.0, y: 20.0, width: (barChartPageView?.frame.width)! - 120.0, height: (barChartPageView?.frame.height)!/3.0), style: .plain)
            if chart!.frame.minY < self.legendTableView!.frame.maxY {
                chart!.frame = CGRect(origin: CGPoint(x: chart!.frame.minX, y: self.legendTableView!.frame.maxY), size: chart!.frame.size)
            }
            
        }
        
        //Setup legend table
        legendTableView?.separatorStyle = .none
        legendTableView?.dataSource = self
        legendTableView?.delegate = self
        barChartPageView!.addSubview(legendTableView!)
        legendTableView?.reloadData()
        
        //Setup view that will hold gradient
        gradientView = UIView(frame: legendTableView!.frame)
        barChartPageView?.addSubview(gradientView!)
        gradientView!.isUserInteractionEnabled = false
        gradientView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Setup gradient mask
        maskLayer.frame = gradientView!.bounds
        maskLayer.startPoint = CGPoint(x: 0.0, y: 0.85)
        maskLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        let gradientColors = [UIColor.white.withAlphaComponent(0.0).cgColor, UIColor.white.withAlphaComponent(1.0).cgColor]
        maskLayer.colors = gradientColors
        gradientView!.layer.addSublayer(maskLayer)
        
    }
    
    func suffixNumber(number: NSNumber) -> String {
        var num:Double = number.doubleValue;
        let sign = ((num < 0) ? "-" : "" );
        
        num = fabs(num);
        
        if (num < 1000.0){
            return "\(sign)\(num)";
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        let units:[String] = ["K","M","G","T","P","E"];
        
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;
        
        return "\(sign)\(roundedNum)\(units[exp-1])";
    }

    //MARK: - <RCChartViewDataSource>
    
    public func plot(with index: Int, for chartView: RCChartView!) -> RCChartViewPlot! {
        let width = chartView.frame.width / CGFloat(totalTitles!.count) - 5.0
        let plot = RCChartViewPlot(plotAt: index, for: chartView, width: width)
        plot?.layer.cornerRadius = 7.5
        if chartColors!.count > index {
            plot?.backgroundColor = chartColors![index]
            
        } else {
            plot?.backgroundColor = chartColors![index % chartColors!.count]
        }
        
        return plot
    }
    
    public func numberOfPlots(in chartView: RCChartView!) -> Int {
        return (totalValues!.count)
    }
    

//
//    internal func plotWithIndex(index: Int, forChartView chartView: RCChartView!) -> RCChartViewPlot! {
//        
//    }
//    internal func numberOfPlotsInChartView(chartView: RCChartView!) -> Int {
//        return (totalValues!.count)
//    }
    
    internal func chartView(_ chartView: RCChartView!, pointForPlotWith index: Int) -> CGPoint {
        
        
        //Totals page bar chart
        if ((totalValues?.count)! > index) {
            return CGPoint(x: CGFloat(index), y: totalValues![index])
        } else {
            return CGPoint(x: CGFloat(index), y: 0.0)
        }
    }
    
    internal func chartViewMaxX(_ chartView: RCChartView!) -> CGFloat {
        //Return the number of x values
        return CGFloat((totalValues?.count)!)
    }
    
    internal func chartViewMaxY(_ chartView: RCChartView!) -> CGFloat {
        //Return the largest value
        
        let sortedValues = (totalValues! as NSArray).sorted { (first, second) -> Bool in
            if first as! CGFloat > second as! CGFloat {
                return true
            } else {
                return false
            }
        }
        return sortedValues.first as! CGFloat
    }
    
    
    internal func titleForPlot(at index: Int) -> String! {
        //Use the title labels to show the values for the chart
        if (totalTitles?.count)! > index {
            return totalTitles![index]
            
        }
        return ""
    }
    
    //MARK: - <UIScrollViewDelegate>
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == pageScrollView! {
            let pageNumberIndicator = scrollView.contentOffset.x / pageScrollView!.frame.width
            
            if pageNumberIndicator == 0 {
                pageControl!.currentPage = 0
                
            } else if pageNumberIndicator == 1 {
                pageControl!.currentPage = 1
                
            } else if (pageNumberIndicator == 2) {
                pageControl!.currentPage = 2
                
            }
        }
        
    }
    
    //MARK: - <UITableViewDataSource>
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var reusableCellID = ""
        var cellMainText = ""
        var cellDetailText = ""
        var tableViewCell : UITableViewCell?
        
        if tableView == legendTableView {
            //Cell for legendTableView
            
            reusableCellID = "legendCellIdentifier"
            
            tableViewCell = tableView.dequeueReusableCell(withIdentifier: reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .value2, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .none
            
            tableViewCell?.detailTextLabel?.textAlignment = NSTextAlignment.right
            tableViewCell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
            tableViewCell?.detailTextLabel?.numberOfLines = 0
            tableViewCell?.detailTextLabel?.lineBreakMode = .byWordWrapping
            let totalVal = NumberFormatter.localizedString(from: (totalValues![indexPath.row] as NSNumber), number: NumberFormatter.Style.currency)
            
            if (totalTitles?.count)! > indexPath.row && (totalValues?.count)! > indexPath.row {
                tableViewCell!.detailTextLabel?.text = " \(totalTitles![indexPath.row]): \(totalVal)"
            }
            
            //Only add legend color view if it doesn't exist on the cell already
            var colorExists = false
            var colorView: UIView!
            for view in tableViewCell!.contentView.subviews {
                if view.tag == 1 {
                    colorExists = true
                    colorView = view
                    break
                }
            }
            if colorExists == false {
                colorView = UIView(frame: CGRect(x: 0.0, y: 12.5, width: 20.0, height: 20.0))
                colorView.layer.cornerRadius = 10.0
                colorView.layer.masksToBounds = true
                colorView.layer.allowsEdgeAntialiasing = true
                colorView.tag = 1
                tableViewCell?.contentView.addSubview(colorView)
            }
            
            if chartColors!.count > indexPath.row {
                colorView.backgroundColor = chartColors![indexPath.row]
            } else {
                if (chartColors?.count)! > 0 {
                    colorView.backgroundColor = chartColors![indexPath.row % chartColors!.count]
                }
            }
            
            
        } else if tableView == propertiesTableView {
            //Cell for propertiesTableView
            
            reusableCellID = "propertiesCellIdentifier"
            
            if (propertyTitles?.count)! > indexPath.row {
                cellMainText = "\(propertyTitles![indexPath.row])"
            }
            
            if (propertyTitles?.count)! > indexPath.row {
                cellDetailText = "\(propertyValues![indexPath.row])"
            }
            
            tableViewCell = tableView.dequeueReusableCell(withIdentifier: reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .value1, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .blue
            tableViewCell!.textLabel?.text = cellMainText
            tableViewCell!.detailTextLabel?.text = cellDetailText
            
        } else if tableView == linksTableView {
            //Cell for linksTableView
            if let source = linksDataSource {
                return source.resourceViewController(viewController: self, tableView: tableView, cellForLinkAtPath: indexPath)
            }
            
            reusableCellID = "LinkTableCell"
            
            if (linkTitles?.count)! > indexPath.row {
                cellMainText = "\(linkTitles![indexPath.row])"
            }
            
            if (linkDescriptions?.count)! > indexPath.row {
                cellDetailText = "\(linkDescriptions![indexPath.row])"
            }
            
            tableViewCell = tableView.dequeueReusableCell(withIdentifier: reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .value1, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .blue
            tableViewCell!.textLabel?.text = cellMainText
            tableViewCell!.detailTextLabel?.text = cellDetailText
            
        }
        
        return tableViewCell!

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == legendTableView {
            if totalTitles != nil {
                return (totalTitles!.count)
            } else {
                return 0
            }
            
        } else if tableView == propertiesTableView {
            if propertyTitles != nil {
                return (propertyTitles!.count)
            } else {
                return 0
            }
            
        } else if tableView == linksTableView {
            if let source = linksDataSource {
                return source.resourceViewController(viewController: self, numberOfRowsForLinkSection: section)
                
            } else if linkTitles != nil {
                return (linkTitles!.count)
                
            } else {
                return 0
            }
            
        }
        
        return 0
    }
    
    //MARK: - <UITableViewDelegate>
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == legendTableView {
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in legendTableView")
            
        } else if tableView == propertiesTableView {
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in propertiesTableView")
            
        } else if tableView == linksTableView {
            if let source = linksDataSource {
                source.resourceViewController(viewController: self, didSelectPath: indexPath)
            }
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in linksTableView")
        }
    }
    
    //MARK: - <UICollectionViewDataSource>
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let source = linksDataSource {
            return source.resourceViewController(viewController: self, numberOfRowsForLinkSection: section)
            
        } else {
            return 0
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let source = linksDataSource {
            return source.resourceViewControllerNumberOfLinkSections(viewController: self)
            
        } else {
            return 0
            
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let source = linksDataSource {
            return source.resourceViewControllerNumberOfLinkSections(viewController: self)
            
        } else {
            return 0
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let source = linksDataSource {
            return source.resourceViewController(viewController: self, collectionView: collectionView, cellForLinkAtPath: indexPath)
            
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "LinkCell", for: indexPath)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let source = linksDataSource {
            return source.resourceViewController(viewController: self, didSelectPath: indexPath)
        }
    }
    
}


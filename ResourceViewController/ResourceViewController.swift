//
//  ViewController.swift
//  ResourcesViewController
//
//  Created by Yishak Abraham on 6/3/16.
//  Copyright © 2016 RigilCorp. All rights reserved.
//

import UIKit

class ResourceViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, RCChartViewDataSource {

    private var pageScrollView: UIScrollView?
    
    private var pageControl: UIPageControl?
    
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
    private let defaultColors = [UIColor(red: 90.0/255.0, green: 200.0/255.0, blue: 250/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0), UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
    
    //Properties view and properties
    private var propertiesPageView : UIView?
    private var propertiesTableView : UITableView?
    private var properties : [NSDictionary]?
    private var propertyTitles : [String]?
    private var propertyValues : [String]?
    
    //Links view and properties
    private var linksPageView : UIView?
    private var linksTableView : UITableView?
    private var links : [NSDictionary]?
    private var linkTitles : [String]?
    private var linkDescriptions : [String]?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None;
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        //Set up scrollView
        pageScrollView = UIScrollView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 30.0))
        self.view.addSubview(pageScrollView!)
        pageScrollView!.pagingEnabled = true
        pageScrollView!.autoresizingMask = [.FlexibleWidth,  .FlexibleHeight]
        pageScrollView!.delegate = self
        pageScrollView?.canCancelContentTouches = false
        
        pageControl = UIPageControl(frame: CGRectMake(0.0, CGRectGetHeight(self.view.frame) - 30.0, 50.0, 30.0))
        pageControl?.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, pageControl!.center.y)
        pageControl?.numberOfPages = 3
        pageControl?.currentPage = 0
        pageControl?.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl?.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl?.autoresizingMask = [.FlexibleTopMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
        self.view.addSubview(pageControl!)
        
        //Create and add the barchartPageView to the scrollview which is going to be on the first page
        barChartPageView = UIView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(pageScrollView!.frame), CGRectGetHeight(pageScrollView!.frame)))
        barChartPageView?.autoresizingMask = [.FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight]
        
        legendTableView = UITableView.init(frame: CGRectMake(CGRectGetMaxX(self.view.frame) - (CGRectGetMaxX(self.view.frame) / 4.0) - 20.0, 100.0, CGRectGetMaxX(self.view.frame) / 4.0, CGRectGetMaxY(self.view.frame)), style: .Grouped)
        
        pageScrollView!.addSubview(barChartPageView!)
        
        
        //Create and add the propertiesPageView to the scrollview which is going to be on the second page
        propertiesPageView = UIView(frame: CGRectMake(CGRectGetWidth(pageScrollView!.frame), 0.0, CGRectGetWidth(pageScrollView!.frame), CGRectGetHeight(pageScrollView!.frame)))
        propertiesPageView?.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleHeight]
        
        propertiesTableView = UITableView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth((propertiesPageView?.frame)!), CGRectGetHeight(propertiesPageView!.frame)), style: UITableViewStyle.Plain)
        propertiesTableView?.dataSource = self
        propertiesTableView?.delegate = self
        propertiesTableView?.cellLayoutMarginsFollowReadableWidth = false
        propertiesTableView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        //Add propertiesTableView to propertiesPageView
        propertiesPageView!.addSubview(propertiesTableView!)

        //Add propertiesPageView to pageScrollView so that it is place on the second page
        pageScrollView!.addSubview(propertiesPageView!)
        
        
        //Create and add the linksPageView to the scrollview which is going to be on the third page
        linksPageView = UIView(frame: CGRectMake(CGRectGetWidth(pageScrollView!.frame) * 2, 0.0, CGRectGetWidth(pageScrollView!.frame), CGRectGetHeight(pageScrollView!.frame)))
        linksPageView?.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleHeight]
        linksTableView = UITableView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth((linksPageView?.frame)!), CGRectGetHeight((linksPageView?.frame)!)), style: UITableViewStyle.Plain)
        linksTableView?.dataSource = self
        linksTableView?.delegate = self
        linksTableView?.cellLayoutMarginsFollowReadableWidth = false
        linksTableView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        //Add linkTableView to linkPageView
        linksPageView!.addSubview(linksTableView!)
        
        //Add linkPageView to pageScrollView so that it is place on the second page
        pageScrollView!.addSubview(linksPageView!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        pageScrollView!.contentSize = CGSizeMake(CGRectGetWidth(pageScrollView!.frame) * 3, CGRectGetHeight(pageScrollView!.frame)-64)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.adjustForSize(size)
        coordinator.animateAlongsideTransition(nil) { (context) in
            //sometimes have to readjust if the size is different after transition,
            //than what was expected
            if self.view.frame.size != size {
                self.adjustForSize(self.view.frame.size)
            }
        }
        

    }
    
    func adjustForSize(size: CGSize) {
        pageScrollView!.contentSize = CGSize(width: size.width*3.0, height: size.height-30.0)
        if size.width >= size.height {
            //setup for landscape
            var y = (size.height-30.0) - (size.height-30.0) / 3.0 * 2.0 - 100.0
            y = (y < 20) ? 20.0 : y
            self.chart?.frame = CGRectMake(80.0, y, (size.width)/3.0*2.0 - 100.0, (size.height-30.0) / 3.0 * 2.0)
            self.legendTableView?.frame = CGRectMake(CGRectGetMaxX(self.chart!.frame) + 20.0, 20.0, size.width/3.0-25.0 , CGRectGetHeight(self.chart!.frame)/3.0*2.0)
            
        } else {
            //setup for portrait
            var y = (size.height-30.0) / 2.0 - 70.0
            y =  (y < (size.height-30.0)/3.0 + 20.0) ? (size.height-30.0)/3.0 + 20.0 : y
            self.chart?.frame = CGRectMake(80.0, y, size.width-120.0, ((size.height-30.0) / 2.0) - 70.0)
            self.legendTableView?.frame = CGRectMake(80.0 , 20.0, size.width-120.0, (size.height-30.0)/3.0)
            
        }
        let xLabelHeight = CGRectGetWidth(chart!.frame) / CGFloat(totalTitles!.count) - 8.0
        chart!.titlesHeight = xLabelHeight
        chart!.titlesFont = UIFont.systemFontOfSize(10.0 + CGRectGetWidth(chart!.frame)/100.0)
        self.yAxisLabelsContainerView!.frame = CGRectMake(0.0, CGRectGetMinY(self.chart!.frame), 80.0,  CGRectGetHeight(self.chart!.frame))
        self.gradientView?.frame = self.legendTableView!.frame
        self.maskLayer.frame = gradientView!.bounds
        chart?.reloadData()
    }
    
    //MARK: - Public
    func setup(totals totals: [String: AnyObject], properties: [String: AnyObject], links: [String: AnyObject], colors: [UIColor]) {
        
        if colors.count > 0 {
            chartColors = colors
        } else {
            chartColors = defaultColors
        }
        
        //Get the totalTitles, totalValues, propetyTitles, propertyValues, links
        totalTitles = Array(totals.keys)
        
        for title in totalTitles! {
            if totalValues == nil {
                totalValues = [CGFloat(totals[title] as! NSNumber)]
            } else {
                totalValues?.append(CGFloat(totals[title] as! NSNumber))
            }
        }
        
        propertyTitles = Array(properties.keys)
        
        for proTitle in propertyTitles! {
            if propertyValues == nil {
                propertyValues = [properties[proTitle] as! String]
            } else {
                propertyValues?.append(properties[proTitle] as! String)
            }
        }
        
        linkTitles = Array(links.keys)
        
        for linkTitle in linkTitles! {
            
            if linkDescriptions == nil {
                linkDescriptions = [links[linkTitle] as! String]
                
            } else {
                linkDescriptions?.append(links[linkTitle] as! String)
            }
            
        }
        
        if totalValues != nil && totalValues != nil {
            
            //Create and setup chart
            self.createChart(totalTitles!, values: totalValues!, colors: defaultColors)
            
            //Create and legend table
            self.createLegendView(totalTitles!, values: totalValues!, colors: defaultColors)
            
            propertiesTableView?.reloadData()
            linksTableView?.reloadData()
            
        } else {
            print("ResourceViewController - Please pass the right dictionary objects")
        }
        
    }
    
    func modify(totals totals: [String: AnyObject], properties: [String: AnyObject], links: [String: AnyObject], colors: [UIColor]) {
        
        if colors.count > 0 {
            chartColors = colors
        } else {
            chartColors = defaultColors
        }
        
        //Get the totalTitles, totalValues, propetyTitles, propertyValues, links
        
        totalTitles = Array(totals.keys)
        totalValues?.removeAll()
        
        for title in totalTitles! {
            if totalValues == nil {
                totalValues = [CGFloat(totals[title] as! NSNumber)]
            } else {
                totalValues?.append(CGFloat(totals[title] as! NSNumber))
            }
        }
        
        propertyTitles = Array(properties.keys)
        propertyValues?.removeAll()
        
        for proTitle in propertyTitles! {
            if propertyValues == nil {
                propertyValues = [properties[proTitle] as! String]
            } else {
                propertyValues?.append(properties[proTitle] as! String)
            }
        }
        
        
        linkTitles = Array(links.keys)
        linkDescriptions?.removeAll()
        
        for linkTitle in linkTitles! {
            
            if linkDescriptions == nil {
                linkDescriptions = [links[linkTitle] as! String]
            } else {
                linkDescriptions?.append(links[linkTitle] as! String)
            }
            
        }
        
        chart!.reloadData()
        legendTableView?.reloadData()
        propertiesTableView?.reloadData()
        linksTableView?.reloadData()
        

    }
    
    
    //MARK: - Private
    
    private func createChart(titles: [String], values:[CGFloat], colors:[UIColor]) {
        
        //Sort Values to find the highest value to create labels
        let sortedValues = (values as NSArray).sort { (first, second) -> Bool in
            if first as! CGFloat > second as! CGFloat {
                return true
            } else {
                return false
            }
        }
        
        if self.view.frame.size.width >= self.view.frame.size.height {
            //setup for landscape
            var y = CGRectGetHeight(barChartPageView!.frame) - (CGRectGetHeight(barChartPageView!.frame)) / 3.0 * 2.0 - 100.0
            y = (y < 20) ? 20.0 : y
            chart = RCChartView(frame: CGRectMake(80.0, y, (CGRectGetWidth(pageScrollView!.frame))/3.0*2.0 - 100.0, (CGRectGetHeight(barChartPageView!.frame)) / 3.0 * 2.0), style: RCChartStyleBar)
            
        } else {
            //setup for portrait
            chart = RCChartView(frame: CGRectMake(80.0, (CGRectGetHeight(pageScrollView!.frame)) / 2.0 - 70.0, CGRectGetWidth(pageScrollView!.frame)-120.0, (CGRectGetHeight(pageScrollView!.frame) / 2.0) - 70.0), style: RCChartStyleBar)
            
        }
        
        var index = 0
        let labelHeight = CGRectGetHeight(chart!.frame) / CGFloat(5)
        
        yAxisLabelsContainerView = UIView(frame: CGRectMake(0.0, CGRectGetMinY(self.chart!.frame), 80.0,  CGRectGetHeight(self.chart!.frame)))

        for i in 0 ... 4 {
            
            let chartLabel = UILabel(frame: CGRectMake( 0.0 , (labelHeight * CGFloat(index)) , 75.0, 20.0))
            var value = CGFloat(0.0)
            if i == 0 {
                value = CGFloat(sortedValues.first as! NSNumber)
            } else {
                value = CGFloat(sortedValues.first as! NSNumber) * (CGFloat(5 - i) / 5)
            }
            chartLabel.textAlignment = NSTextAlignment.Right
            chartLabel.font = UIFont.systemFontOfSize(15.0)
            chartLabel.text = "\(self.suffixNumber(NSNumber(float: Float(value))))"
            yAxisLabelsContainerView?.addSubview(chartLabel)

            index += 1
        }
        
        barChartPageView?.addSubview(yAxisLabelsContainerView!)

        //Setup Chart subviews
        chart!.titlesColor = UIColor.darkTextColor()
        let xLabelHeight = CGRectGetWidth(chart!.frame) / CGFloat(totalTitles!.count) - 8.0
        chart!.titlesHeight = xLabelHeight
        chart!.titlesFont = UIFont.systemFontOfSize(10.0 + CGRectGetWidth(chart!.frame)/100.0)
        chart?.titleTextAlignment = NSTextAlignment.Left
        chart!.displayTitles = true
        chart!.userInteractionEnabled = true
        chart!.dataSource = self
        
        barChartPageView!.addSubview(chart!)
        chart!.reloadData()
        
    }
    
    private func createLegendView(titles: [String], values:[CGFloat], colors:[UIColor]) {
        //Setup LegendTableView based on device type and orientation
        
        if self.view.frame.size.width >= self.view.frame.size.height {
            //setup for landscape
            self.legendTableView = UITableView(frame: CGRectMake(CGRectGetMaxX(self.chart!.frame) + 20.0, 20.0, CGRectGetWidth(barChartPageView!.frame)/3.0-25.0 , CGRectGetHeight(self.chart!.frame)/3.0*2.0), style: .Plain)
            
        } else {
            //setup for portrait
            self.legendTableView = UITableView(frame: CGRectMake(80.0, 20.0, CGRectGetWidth(barChartPageView!.frame) - 120.0, (CGRectGetHeight(barChartPageView!.frame))/3.0), style: .Plain)
            if CGRectGetMinY(chart!.frame) < CGRectGetMaxY(self.legendTableView!.frame) {
                chart!.frame = CGRect(origin: CGPoint(x: CGRectGetMinX(chart!.frame), y: CGRectGetMaxY(self.legendTableView!.frame)), size: chart!.frame.size)
            }
            
        }
        
        //Setup legend table
        legendTableView?.separatorStyle = .None
        legendTableView?.dataSource = self
        legendTableView?.delegate = self
        barChartPageView!.addSubview(legendTableView!)
        legendTableView?.reloadData()
        
        //Setup view that will hold gradient
        gradientView = UIView(frame: legendTableView!.frame)
        barChartPageView?.addSubview(gradientView!)
        gradientView!.userInteractionEnabled = false
        gradientView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        //Setup gradient mask
        maskLayer.frame = gradientView!.bounds
        maskLayer.startPoint = CGPoint(x: 0.0, y: 0.85)
        maskLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        let gradientColors = [UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(1.0).CGColor]
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
    
    internal func plotWithIndex(index: Int, forChartView chartView: RCChartView!) -> RCChartViewPlot! {
        let width = CGRectGetWidth(chartView.frame) / CGFloat(totalTitles!.count) - 5.0
        let plot = RCChartViewPlot(plotAtIndex: index, forChartView: chartView, width: width)
        plot.layer.cornerRadius = 7.5
        if chartColors!.count > index {
            plot.backgroundColor = chartColors![index]
            
        } else {
            plot.backgroundColor = chartColors![index % chartColors!.count]
        }
        
        return plot
    }
    
    internal func pointForPlotWithIndex(index: Int) -> CGPoint {
        
        if (totalValues?.count > index) {
            return CGPointMake(CGFloat(index), totalValues![index])
        } else {
            return CGPointMake(CGFloat(index), 0.0)
        }
        
    }
    
    internal func chartViewMaxX(chartView: RCChartView!) -> CGFloat {
        //Return the number of x values
        return CGFloat((totalValues?.count)!)
    }
    
    internal func chartViewMaxY(chartView: RCChartView!) -> CGFloat {
        //Return the largest value
        
        let sortedValues = (totalValues! as NSArray).sort { (first, second) -> Bool in
            if first as! CGFloat > second as! CGFloat {
                return true
            } else {
                return false
            }
        }
        return sortedValues.first as! CGFloat
    }
    
    internal func numberOfPlotsInChartView(chartView: RCChartView!) -> Int {
        return (totalValues!.count)
    }
    
    internal func titleForPlotAtIndex(index: Int) -> String! {
        //Use the title labels to show the values for the chart
        if totalTitles?.count > index {
            return totalTitles![index]
            
        }
        return ""
    }
    
    
    //MARK: - <UIScrollViewDelegate>
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == pageScrollView! {
            let pageNumberIndicator = scrollView.contentOffset.x / CGRectGetWidth(pageScrollView!.frame)
            
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reusableCellID = ""
        var cellMainText = ""
        var cellDetailText = ""
        var tableViewCell : UITableViewCell?
        
        if tableView == legendTableView {
            //Cell for legendTableView
            
            reusableCellID = "legendCellIdentifier"
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .Value2, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .None
            
            tableViewCell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
            tableViewCell?.detailTextLabel?.font = UIFont.systemFontOfSize(15.0)
            tableViewCell?.detailTextLabel?.numberOfLines = 0
            tableViewCell?.detailTextLabel?.lineBreakMode = .ByWordWrapping
            let totalVal = NSNumberFormatter.localizedStringFromNumber((totalValues![indexPath.row] as NSNumber), numberStyle: NSNumberFormatterStyle.CurrencyStyle)

            if totalTitles?.count > indexPath.row && totalValues?.count > indexPath.row {
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
                colorView = UIView(frame: CGRectMake(0.0, 12.5, 20.0, 20.0))
                colorView.layer.cornerRadius = 10.0
                colorView.layer.masksToBounds = true
                colorView.layer.allowsEdgeAntialiasing = true
                colorView.tag = 1
                tableViewCell?.contentView.addSubview(colorView)
            }
            
            if chartColors!.count > indexPath.row {
                colorView.backgroundColor = chartColors![indexPath.row]
            } else {
                if chartColors?.count > 0 {
                    colorView.backgroundColor = chartColors![indexPath.row % chartColors!.count]
                }
            }
            
            
        } else if tableView == propertiesTableView {
            //Cell for propertiesTableView
            
            reusableCellID = "propertiesCellIdentifier"
            
            if propertyTitles?.count > indexPath.row {
                cellMainText = "\(propertyTitles![indexPath.row])"
            }
            
            if propertyTitles?.count > indexPath.row {
                cellDetailText = "\(propertyValues![indexPath.row])"
            }
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .Blue
            tableViewCell!.textLabel?.text = cellMainText
            tableViewCell!.detailTextLabel?.text = cellDetailText
            
        } else if tableView == linksTableView {
            //Cell for linksTableView

            reusableCellID = "linkCellIdentifier"
            
            if linkTitles?.count > indexPath.row {
                cellMainText = "\(linkTitles![indexPath.row])"
            }
            
            if linkDescriptions?.count > indexPath.row {
                cellDetailText = "\(linkDescriptions![indexPath.row])"
            }
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .Blue
            tableViewCell!.textLabel?.text = cellMainText
            tableViewCell!.detailTextLabel?.text = cellDetailText
            
        }
        
        return tableViewCell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            if linkTitles != nil {
                return (linkTitles!.count)
            } else {
                return 0
            }
            
        }
        
        return 0
    }
    
    //MARK: - <UITableViewDelegate>
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == legendTableView {
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in legendTableView")
            
        } else if tableView == propertiesTableView {
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in propertiesTableView")
            
        } else if tableView == linksTableView {
            print("ResrouceViewController - Tapped on a cell at row \(indexPath.row) in linksTableView")
        }
    }
    
}


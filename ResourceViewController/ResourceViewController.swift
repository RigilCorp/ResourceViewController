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
    
    private var pageCont: UIPageControl?
    
    //Bar chart view and properties
    private var barChartPageView : UIView?
    private var yAxisLabelsContainerView : UIView?
    private var chart : RCChartView?
    private var legendTableView : UITableView?
    private var totalValues : [CGFloat]?
    private var totalTitles : [String]?
    private var chartColors : [UIColor]?
    private var plots : [RCChartViewPlot]?
    private var maskLayer : CAGradientLayer?
    private var gradientView : UIView?
    private let defaultColors = [UIColor(red: 90.0/255.0, green: 200.0/255.0, blue: 250/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0), UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)]
    
    //Properties view and properties
    private var  propertiesPageView : UIView?
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
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Set up scrollView
        pageScrollView = UIScrollView(frame: CGRectMake(0.0, 0.0, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) - 50.0))

        self.view.addSubview(pageScrollView!)
        pageScrollView!.contentSize = CGSizeMake(CGRectGetWidth(pageScrollView!.frame) * 3, CGRectGetHeight(pageScrollView!.frame))
        pageScrollView!.pagingEnabled = true
        pageScrollView!.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,  UIViewAutoresizing.FlexibleHeight]
        pageScrollView!.delegate = self
        pageScrollView?.showsVerticalScrollIndicator = false
        pageScrollView?.showsHorizontalScrollIndicator = false
        pageScrollView?.canCancelContentTouches = false
        pageCont = UIPageControl(frame: CGRectMake(0.0, CGRectGetHeight(self.view.frame) - 50.0, 50.0, 30.0))
        pageCont?.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, pageCont!.center.y)
        
        pageCont?.numberOfPages = 3
        pageCont?.currentPage = 0
        pageCont?.currentPageIndicatorTintColor = UIColor.blackColor()
        pageCont?.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.view.addSubview(pageCont!)
        
        //Create and add the barchartPageView to the scrollview which is going to be on the first page
        barChartPageView = UIView.init(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(pageScrollView!.frame), CGRectGetHeight(pageScrollView!.frame)))
        
        legendTableView = UITableView.init(frame: CGRectMake(CGRectGetMaxX(self.view.frame) - (CGRectGetMaxX(self.view.frame) / 4.0) - 20.0, 100.0, CGRectGetMaxX(self.view.frame) / 4.0, CGRectGetMaxY(self.view.frame)), style: .Grouped)
        
        pageScrollView!.addSubview(barChartPageView!)
        
        
        //Create and add the propertiesPageView to the scrollview which is going to be on the second page
        propertiesPageView = UIView.init(frame: CGRectMake(CGRectGetMaxX(pageScrollView!.frame), 0.0, CGRectGetMaxY(self.view.frame) - 200.0, CGRectGetHeight(pageScrollView!.frame)))
        
        propertiesTableView = UITableView.init(frame: CGRectMake(100.0, 0.0, CGRectGetWidth((propertiesPageView?.frame)!) - 100.0, CGRectGetHeight((propertiesPageView?.frame)!)), style: UITableViewStyle.Plain)
        propertiesTableView?.dataSource = self
        propertiesTableView?.delegate = self
        propertiesTableView?.cellLayoutMarginsFollowReadableWidth = false

        //Add propertiesTableView to propertiesPageView
        propertiesPageView!.addSubview(propertiesTableView!)

        //Add propertiesPageView to pageScrollView so that it is place on the second page
        pageScrollView!.addSubview(propertiesPageView!)
        
        
        //Create and add the linksPageView to the scrollview which is going to be on the third page
        linksPageView = UIView.init(frame: CGRectMake(CGRectGetMaxX(pageScrollView!.frame) * 2, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(pageScrollView!.frame)))
        linksTableView = UITableView.init(frame: CGRectMake(0.0, 0.0, CGRectGetWidth((linksPageView?.frame)!), CGRectGetHeight((linksPageView?.frame)!)), style: UITableViewStyle.Plain)
        linksTableView?.dataSource = self
        linksTableView?.delegate = self
        linksTableView?.cellLayoutMarginsFollowReadableWidth = false
        
        //Add linkTableView to linkPageView
        linksPageView!.addSubview(linksTableView!)
        
        //Add linkPageView to pageScrollView so that it is place on the second page
        pageScrollView!.addSubview(linksPageView!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var minXForPropertiesPage  = CGFloat(0.0)
        var minXForLinksPage = CGFloat(0.0)
        
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
            minXForPropertiesPage = CGRectGetMaxY(self.view.frame)
            minXForLinksPage = CGRectGetMaxY(self.view!.frame) * 2
            
        } else if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
            minXForPropertiesPage = CGRectGetMaxX(self.view.frame)
            minXForLinksPage = CGRectGetMaxX(self.view.frame) * 2
        }
        //Setup views that act as pages in the scrollview
        pageScrollView!.frame = CGRectMake(0.0, 65.0, minXForPropertiesPage, CGRectGetMaxY(self.view.frame) - 65.0)
        barChartPageView!.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.pageScrollView!.frame))
        propertiesPageView?.frame = CGRectMake(minXForPropertiesPage, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        propertiesTableView?.frame = CGRectMake(20.0, 0.0, CGRectGetWidth(self.view.frame) - 40.0, CGRectGetHeight(self.view.frame))
        linksPageView?.frame = CGRectMake(minXForLinksPage, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        linksTableView?.frame = CGRectMake(20.0, 0.0, CGRectGetWidth(self.view.frame) - 40.0, CGRectGetHeight((linksPageView?.frame)!))
        pageScrollView!.contentSize = CGSizeMake(CGRectGetWidth(pageScrollView!.frame) * 3, CGRectGetHeight(pageScrollView!.frame))

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone && (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft) {
            print("iPhone")

            self.pageCont?.frame = CGRectMake(0.0, CGRectGetHeight(self.view.frame) - 25.0, 50.0, 30.0)
            self.pageCont?.center = CGPointMake(CGRectGetMaxX(self.view.frame) / 2.0, self.pageCont!.center.y)
        } else {
            self.pageCont?.frame = CGRectMake(0.0, CGRectGetHeight(self.view.frame) - 50.0, 50.0, 30.0)
            self.pageCont?.center = CGPointMake(CGRectGetMaxX(self.view.frame) / 2.0, self.pageCont!.center.y)
        }
        
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    
        //Prepare views for the toInterfaceOrientation to be rotated to
        if toInterfaceOrientation.isLandscape && CGRectGetHeight(self.view.frame) > CGRectGetWidth(self.view.frame) || toInterfaceOrientation.isPortrait && CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame) {
            
            var pagesWidth = CGFloat(0.0)
            let pagesHeight = CGRectGetWidth(self.view.frame) - 65.0
            let tablesWidth = CGRectGetHeight(self.view.frame)
            
            if toInterfaceOrientation.isPortrait {
                pagesWidth = CGRectGetWidth(self.view.frame)
                
                
                if UIUserInterfaceIdiom.Pad == UI_USER_INTERFACE_IDIOM() {
                    self.pageScrollView?.frame = CGRectMake(0.0, 65.0, pagesWidth * 1.25 , CGRectGetHeight(self.view.frame))
                } else if UIUserInterfaceIdiom.Phone == UI_USER_INTERFACE_IDIOM() {
                    self.pageScrollView?.frame = CGRectMake(0.0, 65.0, pagesWidth * 1.45 , CGRectGetHeight(self.view.frame))
                }
                
            } else if toInterfaceOrientation.isLandscape {
                pagesWidth = CGRectGetHeight(self.view.frame)
                self.pageScrollView?.frame = CGRectMake(0.0, 65.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 65.0)
            }
            
            
            
            self.barChartPageView!.frame = CGRectMake( 0.0, 0.0, tablesWidth, pagesHeight)
            self.propertiesPageView!.frame = CGRectMake(pagesWidth, 0.0, tablesWidth, pagesHeight)
            self.propertiesTableView?.frame = CGRectMake(20.0, 0.0, tablesWidth - 40.0, pagesHeight)
            
            self.linksPageView!.frame = CGRectMake( pagesWidth * 2.0 , 0.0, tablesWidth, pagesHeight)
            self.linksTableView?.frame = CGRectMake(20.0, 0.0, tablesWidth - 40.0, pagesHeight)
            
            self.pageCont?.center = CGPointMake(self.view.center.x, CGRectGetWidth(self.view.frame) - 50.0)
            
            pageScrollView?.contentSize = CGSizeMake(pagesWidth * 3 + 20.0, pagesHeight)
            pageScrollView?.contentOffset.x = CGFloat((pageCont?.currentPage)!) * CGFloat(pagesWidth)
            
            
            if toInterfaceOrientation.isPortrait {
                
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
                    
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.legendTableView?.frame = CGRectMake(CGRectGetMaxX(self.barChartPageView!.frame) / 2.0 - 20.0 , 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 2.0, CGRectGetMaxY(self.barChartPageView!.frame)/3.0)
                        self.chart?.frame = CGRectMake(150.0, CGRectGetHeight(self.view.frame) / 2.0, CGRectGetHeight(self.view.frame) - 200.0, (CGRectGetHeight(self.pageScrollView!.frame) / 2.0) - 70.0)
                        
                        self.yAxisLabelsContainerView!.frame = CGRectMake(CGRectGetMinX(self.chart!.frame) - 75.0, CGRectGetMinY(self.chart!.frame) - 30.0, 100.0,  CGRectGetHeight(self.chart!.frame))
                    })
                    
                } else {
                    
                    UIView.animateWithDuration(0.5, animations: {
                        self.legendTableView!.frame = CGRectMake(CGRectGetMaxX(self.barChartPageView!.frame) / 2.0 - 20.0 , 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 2.0, CGRectGetMaxY(self.barChartPageView!.frame)/4.0)
                        
                        
                        self.chart?.frame = CGRectMake(75.0, (CGRectGetHeight(self.barChartPageView!.frame) / 2.5), CGRectGetWidth(self.view.frame) - 100.0, (CGRectGetHeight(self.pageScrollView!.frame) / 2.0))
                        
                        self.yAxisLabelsContainerView!.frame = CGRectMake(0.0, CGRectGetMinY(self.chart!.frame), 100.0,  CGRectGetHeight(self.chart!.frame))
                        
                    })
                }
                
            } else if toInterfaceOrientation.isLandscape {
                
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
                    
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.chart?.frame = CGRectMake(150.0, 50.0, CGRectGetMaxX(self.barChartPageView!.frame) / 2.0, CGRectGetMaxY(self.barChartPageView!.frame) / 2.0)
                        self.chart!.center = CGPointMake((self.chart?.center.x)!, (self.view!.center.x) - 50.0)
                        self.legendTableView?.frame = CGRectMake(CGRectGetMaxX(self.chart!.frame) + 50.0, 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 3.0, CGRectGetMaxY(self.legendTableView!.frame))
                        self.yAxisLabelsContainerView!.frame = CGRectMake(CGRectGetMinX(self.chart!.frame) - 75.0, CGRectGetMinY(self.chart!.frame) - 30.0, 100.0,  CGRectGetHeight(self.chart!.frame))
                    })
                    
                } else {
                    
                    UIView.animateWithDuration(0.5, animations: {
                        
                        self.legendTableView?.frame = CGRectMake(CGRectGetMaxX(self.barChartPageView!.frame) - (CGRectGetMaxX(self.barChartPageView!.frame) / 3.0) - 20.0, 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 3.0, CGRectGetMaxY(self.barChartPageView!.frame) / 2.0)
                        self.chart!.frame = CGRectMake(80.0, 0.0, CGRectGetMaxX(self.view.frame) * 1/3, CGRectGetMaxY(self.pageScrollView!.frame) / 2.0)
                        self.yAxisLabelsContainerView!.frame = CGRectMake(0.0, CGRectGetMinY(self.chart!.frame), 100.0,  CGRectGetHeight(self.chart!.frame))
                        
                    })
                    self.pageCont?.center = CGPointMake(self.view.center.x, CGRectGetWidth(self.view.frame) - 15.0)
                }
            }
            
            
            gradientView!.frame = legendTableView!.frame
            
            maskLayer!.frame = gradientView!.bounds
            
            let gradientColors = [UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(1.0).CGColor]
            
            maskLayer!.startPoint = CGPoint(x: 0.0, y: 0.85)
            maskLayer!.endPoint = CGPoint(x: 0.0, y: 1.0)
            maskLayer!.colors = gradientColors
            gradientView!.layer.addSublayer(maskLayer!)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - Public Setup Functions
    func setupResourceViewController(totals totals: [String: AnyObject], properties: [String: AnyObject], links: [String: AnyObject], colors: [UIColor]) {
        
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
            self.createChartForTitlesAndValues(totalTitles!, values: totalValues!, colors: defaultColors)
            
            //Create and legend table
            self.createLegendViewForTitlesAndValues(totalTitles!, values: totalValues!, colors: defaultColors)
            
            propertiesTableView?.reloadData()
            linksTableView?.reloadData()
            
        } else {
            print("ResourceViewController - Please pass the right dictionary objects")
        }
        
    }
    
    func modifyResourceViewController(totals totals: [String: AnyObject], properties: [String: AnyObject], links: [String: AnyObject], colors: [UIColor]) {
        
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
        
        
        //Create the plot views and add them to the plots array
        plots?.removeAll()
        chart?.reloadData()
        
        plots = [RCChartViewPlot]()
        
        for index in 0 ... totalValues!.count {
            var width : CGFloat?
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
                width = 30.0
            } else {
                width = 50.0
            }
            
            let plot = RCChartViewPlot.init(plotAtIndex: index, forChartView: chart, width: width!)
            plot.layer.cornerRadius = 5.0
            
            if chartColors!.count > index {
                plot.backgroundColor = chartColors![index]
            } else {
                plot.backgroundColor = chartColors![index % chartColors!.count]
            }
            
            plots?.append(plot)
            
        }
        
        chart!.reloadData()
        legendTableView?.reloadData()
        propertiesTableView?.reloadData()
        linksTableView?.reloadData()
        

    }
    
    
    //MARK: - Private
    private func createChartForTitlesAndValues(titles: [String], values:[CGFloat], colors:[UIColor]) {
        
        //Sort Values to find the highest value to create labels
        let sortedValues = (values as NSArray).sort { (first, second) -> Bool in
            if first as! CGFloat > second as! CGFloat {
                return true
            } else {
                return false
            }
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            
            if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
                chart = RCChartView.init(frame: CGRectMake(150.0, CGRectGetWidth(self.view.frame) / 2.0, CGRectGetMaxY(barChartPageView!.frame) / 2.0, CGRectGetMaxX(barChartPageView!.frame) / 2.0), style: RCChartStyleBar)
            } else if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
                
                chart = RCChartView.init(frame: CGRectMake(150.0, 50.0, CGRectGetMaxX(barChartPageView!.frame) / 2.0, CGRectGetMaxY(barChartPageView!.frame) / 2.0), style: RCChartStyleBar)
                chart!.center = CGPointMake((chart?.center.x)!, (self.view!.center.y) - 50.0)
            }
            
        } else {
            
            
            if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
                
                chart = RCChartView.init(frame: CGRectMake(75.0, (CGRectGetHeight(self.barChartPageView!.frame) / 2.5), CGRectGetWidth(self.view.frame) * 2.0 / 3.0, (CGRectGetHeight(barChartPageView!.frame) / 2.0 - 75.0)), style: RCChartStyleBar)
            } else if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
                
                chart = RCChartView.init(frame: CGRectMake(100.0, 20.0, CGRectGetMaxY(barChartPageView!.frame) - 50.0, CGRectGetMaxY(self.view!.frame) * 2.0/3.0 - 25.0), style: RCChartStyleBar)
            }
        }
        
        var index = 0
        let labelHeight = CGRectGetHeight(chart!.frame) / CGFloat(5)
        
        yAxisLabelsContainerView = UIView.init(frame: CGRectMake(CGRectGetMinX(self.chart!.frame) - 75.0, CGRectGetMinY(chart!.frame) - 20.0, 75.0,  CGRectGetHeight(chart!.frame)))

        for i in 0 ... 4 {
            
            let chartLabel = UILabel.init(frame: CGRectMake( 0.0 , (labelHeight * CGFloat(index)) , 65.0, 20.0))
            var value = CGFloat(0.0)
            print("\(sortedValues)")
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
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            chart?.titlesFont = UIFont.boldSystemFontOfSize(12.0)
            chart!.titlesWidth = 150.0
        } else {
            chart!.titlesWidth = 150.0
        }
        
        chart?.titleTextAlignment = NSTextAlignment.Left
        chart!.displayTitles = true
        chart!.userInteractionEnabled = true
        chart!.dataSource = self
        
        //Create the plot views and add them to the plots array
        
        plots = [RCChartViewPlot]()
        for index in 0 ... values.count - 1{
            var width : CGFloat?
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {

                width = CGRectGetWidth(chart!.frame) / CGFloat(totalTitles!.count) - 5.0
            } else {
                width = CGRectGetWidth(chart!.frame) / CGFloat(totalTitles!.count) - 5.0
            }
            
            let plot = RCChartViewPlot.init(plotAtIndex: index, forChartView: chart, width: width!)
            plot.layer.cornerRadius = 7.5
            if chartColors!.count > index {
                plot.backgroundColor = chartColors![index]
            } else {
                print("ResourceViewController - Exceeded chart colors \(chartColors!.count % index)")
                plot.backgroundColor = chartColors![index % chartColors!.count]
            }
            
            plots?.append(plot)
            
        }
        
        barChartPageView!.addSubview(chart!)
        chart!.reloadData()
        
    }
    
    private func createLegendViewForTitlesAndValues(titles: [String], values:[CGFloat], colors:[UIColor]) {
        //Setup LegendTableView based on device type and orientation
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            
            if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
                
                self.legendTableView = UITableView.init(frame: CGRectMake(CGRectGetMaxX(self.barChartPageView!.frame) / 2.0 - 20.0 , 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 2.0, CGRectGetMaxY(self.barChartPageView!.frame)/3.0), style: UITableViewStyle.Plain)
                
            } else if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                
                legendTableView = UITableView.init(frame: CGRectMake(CGRectGetMaxX(chart!.frame) + 50.0, 20.0, CGRectGetMaxX(barChartPageView!.frame) / 3.0, CGRectGetMaxY(barChartPageView!.frame) / 2.0), style: UITableViewStyle.Plain)
            }
            
        } else {
            
            if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown {
                
                self.legendTableView = UITableView.init(frame:CGRectMake(CGRectGetMaxX(self.barChartPageView!.frame) / 2.0 - 20.0 , 20.0, CGRectGetMaxX(self.barChartPageView!.frame) / 2.0, CGRectGetMaxY(self.barChartPageView!.frame)/4.0), style: UITableViewStyle.Plain)

            } else if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
                
                legendTableView = UITableView.init(frame: CGRectMake(CGRectGetMaxX(barChartPageView!.frame) - (CGRectGetMaxX(barChartPageView!.frame) / 3.0) - 20.0, 20.0, CGRectGetMaxX(barChartPageView!.frame) / 3.0, CGRectGetMaxY(barChartPageView!.frame) / 2.0), style: UITableViewStyle.Plain)
            }
        }
        
        legendTableView?.dataSource = self
        legendTableView?.delegate = self
        barChartPageView!.addSubview(legendTableView!)
        barChartPageView?.bringSubviewToFront(chart!)
        legendTableView?.reloadData()
        legendTableView?.separatorStyle = .None
        
        
        gradientView = UIView.init(frame: legendTableView!.frame)
        barChartPageView?.addSubview(gradientView!)
        gradientView!.userInteractionEnabled = false
        
        maskLayer = CAGradientLayer()
        maskLayer!.frame = gradientView!.bounds
        
        let gradientColors = [UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(1.0).CGColor]
        maskLayer!.startPoint = CGPoint(x: 0.0, y: 0.85)
        maskLayer!.endPoint = CGPoint(x: 0.0, y: 1.0)
        maskLayer!.colors = gradientColors
        
        gradientView!.layer.addSublayer(maskLayer!)
        
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
        if plots?.count > index {
            return plots![index]
        }
        return RCChartViewPlot()
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
            
            scrollView.contentOffset.y = 0.0
            let pageNumberIndicator = scrollView.contentOffset.x / CGRectGetWidth(pageScrollView!.frame)
            if pageNumberIndicator == 0 {
                pageCont!.currentPage = 0
            } else if pageNumberIndicator == 1 {
                pageCont!.currentPage = 1
            } else if (pageNumberIndicator == 2) {
                pageCont!.currentPage = 2
            }
        }
        
    }
    
    //MARK: - <UITableViewDataSource>
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reusableCellID = ""
        var cellMainText = ""
        var cellDetailText = ""
        var cellStyle : UITableViewCellStyle?

        
        var tableViewCell : UITableViewCell?
        
        if tableView == legendTableView {
            //Cell for legendTableView
            
            reusableCellID = "legendCellIdentifier"
            cellStyle = UITableViewCellStyle.Value2
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: cellStyle!, reuseIdentifier: reusableCellID)
            }
            
            tableViewCell!.selectionStyle = .None
            
            tableViewCell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
            tableViewCell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
            tableViewCell?.detailTextLabel?.font = UIFont.systemFontOfSize(15.0)
            tableViewCell?.detailTextLabel?.numberOfLines = 0
            tableViewCell?.detailTextLabel?.lineBreakMode = .ByWordWrapping
            let totalVal = NSNumberFormatter.localizedStringFromNumber((totalValues![indexPath.row] as NSNumber), numberStyle: NSNumberFormatterStyle.CurrencyStyle)

            if totalTitles?.count > indexPath.row && totalValues?.count > indexPath.row {
                tableViewCell!.detailTextLabel?.text = " \(totalTitles![indexPath.row]): \(totalVal)"
            }
            
            let legendColorView = UILabel.init(frame: CGRectMake(0.0, 12.5, 20.0, 20.0))
            legendColorView.layer.cornerRadius = 10.0
            legendColorView.layer.masksToBounds = true
            legendColorView.layer.allowsEdgeAntialiasing = true
            
            if chartColors!.count > indexPath.row {
                legendColorView.backgroundColor = chartColors![indexPath.row]
            } else {
                if chartColors?.count > 0 {
                    legendColorView.backgroundColor = chartColors![indexPath.row % chartColors!.count]
                }
            }
            
            tableViewCell?.addSubview(legendColorView)
            
        } else if tableView == propertiesTableView {
            //Cell for propertiesTableView
            
            reusableCellID = "propertiesCellIdentifier"
            
            if propertyTitles?.count > indexPath.row {
                cellMainText = "\(propertyTitles![indexPath.row])"
            }
            
            if propertyTitles?.count > indexPath.row {
                cellDetailText = "\(propertyValues![indexPath.row])"
            }
            
            
            
            cellStyle = UITableViewCellStyle.Value1
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: cellStyle!, reuseIdentifier: reusableCellID)
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
            
            cellStyle = UITableViewCellStyle.Value1
            
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(reusableCellID)
            if tableViewCell == nil {
                tableViewCell = UITableViewCell(style: cellStyle!, reuseIdentifier: reusableCellID)
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
            print("Tapped on a cell at row \(indexPath.row) in legendTableView")
            
        } else if tableView == propertiesTableView {
            print("Tapped on a cell at row \(indexPath.row) in propertiesTableView")
            
        } else if tableView == linksTableView {
            print("Tapped on a cell at row \(indexPath.row) in linksTableView")
        }
    }
    
}


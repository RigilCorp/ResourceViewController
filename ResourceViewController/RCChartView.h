//
//  RCChartView.h
//  BubbleChartExample
//
//  Created by Sean Rada on 12/12/13.
//  Copyright (c) 2013 Rigil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCChartViewPlot.h"

typedef enum RCChartStyle {
    RCChartStyleScatter,
    RCChartStyleBar
} RCChartStyle;

@class RCChartView;

//Data Source Delegate
@protocol RCChartViewDataSource <NSObject>

@required
- (RCChartViewPlot *)plotWithIndex:(NSInteger)index forChartView:(RCChartView *)chartView;
- (NSInteger)numberOfPlotsInChartView:(RCChartView *)chartView;
- (CGPoint)pointForPlotWithIndex:(NSInteger)index;
- (CGFloat)chartViewMaxX:(RCChartView *)chartView;
- (CGFloat)chartViewMaxY:(RCChartView *)chartView;

@optional
- (NSString *)titleForPlotAtIndex:(NSInteger)index;
- (UIView *)titleViewForPlotAtIndex:(NSInteger)index;

@end

//_______________________


//Delegate
@protocol RCChartViewDelegate <NSObject>

@optional
- (void)chartViewPlotSingleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;
- (void)chartViewPlotDoubleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;
- (void)chartViewPlotLongPressed:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;

@end
//_______________________

@interface RCChartView : UIView

@property (nonatomic, assign) id <RCChartViewDelegate> delegate;
@property (nonatomic, assign) id <RCChartViewDataSource> dataSource;

@property (nonatomic) RCChartStyle chartStyle;

//Chart title attributes
@property (nonatomic) BOOL displayTitles;
@property (nonatomic) UIFont *titlesFont;
@property (nonatomic) UIColor *titlesColor;
/**Default of 32.0*/
@property (nonatomic) CGFloat titlesHeight;
/**Default of 100.0*/
@property (nonatomic) CGFloat titlesWidth;
@property (nonatomic) NSTextAlignment titleTextAlignment;

- (id)initWithFrame:(CGRect)frame style:(RCChartStyle)style ;
- (void)reloadData;
- (void)clearData;

@end

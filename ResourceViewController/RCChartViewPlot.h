//
//  RCChartViewPlot.h
//  BubbleChartExample
//
//  Created by Sean Rada on 12/12/13.
//  Copyright (c) 2013 Rigil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCChartViewPlot;

@protocol RCChartViewPlotDelegate <NSObject>

@required
- (void)chartViewPlotSingleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;
- (void)chartViewPlotDoubleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;
- (void)chartViewPlotLongPressed:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index;

@end

@class RCChartView;

@interface RCChartViewPlot : UIView

@property (nonatomic) id <RCChartViewPlotDelegate> delegate;

@property (nonatomic, readonly) NSInteger index;

- (id)initPlotAtIndex:(NSInteger)index forChartView:(RCChartView *)chartView width:(CGFloat)width;

@end

//
//  RCChartView.m
//  BubbleChartExample
//
//  Created by Sean Rada on 12/12/13.
//  Copyright (c) 2013 Rigil. All rights reserved.
//

#import "RCChartView.h"

@interface RCChartView () <RCChartViewPlotDelegate> {
    NSMutableArray *plots;
    
    CGFloat xRatio;
    CGFloat yRatio;
    
    CGFloat xMax;
    CGFloat yMax;
}

@end

@implementation RCChartView

@synthesize dataSource;
@synthesize delegate;
@synthesize chartStyle;
@synthesize displayTitles;
@synthesize titlesFont, titlesColor, titlesWidth, titlesHeight, titleTextAlignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        plots = [[NSMutableArray alloc] init];
        
        titlesFont = [UIFont systemFontOfSize:17.0];
        titlesColor = [UIColor whiteColor];
        titlesWidth = 100.0;
        titlesHeight = 32.0;
        titleTextAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(RCChartStyle)style {
    self = [self initWithFrame:frame];
    if (self) {
        chartStyle = style;
    }
    
    return self;
}


- (void)reloadData {
    [self clearData];
    
    xMax = [dataSource chartViewMaxX:self];
    yMax = [dataSource chartViewMaxY:self];
    
    [self setSizeRatios];
    
    NSInteger numOfPlots = [dataSource numberOfPlotsInChartView:self];
    
    //Create plots
    for (NSInteger i = 0; i < numOfPlots; i++) {
        RCChartViewPlot *plot = [dataSource plotWithIndex:i forChartView:self];
        plot.delegate = self;
        
        [plots addObject:plot];
        [self addSubview:plot];
    }
    
    //Create title labels
    if (self.displayTitles) {
        for (NSInteger i = 0; i < numOfPlots; i++) {
            
            //Get title view from delegate method
            if ([dataSource respondsToSelector:@selector(titleViewForPlotAtIndex:)]) {
                UIView *titleView = [dataSource titleViewForPlotAtIndex:i];
                titleView.frame = CGRectMake([self cgpointForChartCoordinates:[dataSource pointForPlotWithIndex:i]].x + titleView.frame.origin.x,
                                             self.frame.size.height - titlesHeight + titleView.frame.origin.y,
                                             titleView.frame.size.width,
                                             titleView.frame.size.height);
                [self addSubview:titleView];
                
            //Get title from delegate method
            } else if ([dataSource respondsToSelector:@selector(titleForPlotAtIndex:)]) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self cgpointForChartCoordinates:[dataSource pointForPlotWithIndex:i]].x - 10.0,
                                                                                self.frame.size.height + titlesWidth*(M_1_PI),
                                                                                titlesWidth,
                                                                                titlesHeight)];
                titleLabel.text = [dataSource titleForPlotAtIndex:i];
                titleLabel.font = titlesFont;
                titleLabel.textColor = titlesColor;
                titleLabel.textAlignment = titleTextAlignment;
                titleLabel.numberOfLines = 0;
                titleLabel.transform = CGAffineTransformMakeRotation(M_PI_4);
                [self addSubview:titleLabel];
            }
        }
    }
}

- (void)setSizeRatios {
    xRatio = self.frame.size.width/xMax;
    yRatio = self.frame.size.height/yMax;
}

- (CGPoint)cgpointForChartCoordinates:(CGPoint)point {
    
    return CGPointMake(xRatio * point.x, self.frame.size.height - yRatio * point.y);
}

- (void)clearData {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark plot delegate method

- (void)chartViewPlotSingleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotSingleTapped:atIndex:)])
        [delegate chartViewPlotSingleTapped:chartViewPlot atIndex:index];
}

- (void)chartViewPlotDoubleTapped:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotDoubleTapped:atIndex:)])
        [delegate chartViewPlotDoubleTapped:chartViewPlot atIndex:chartViewPlot.index];
}

- (void)chartViewPlotLongPressed:(RCChartViewPlot *)chartViewPlot atIndex:(NSInteger)index {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotLongPressed:atIndex:)])
        [delegate chartViewPlotLongPressed:chartViewPlot atIndex:index];
}

@end

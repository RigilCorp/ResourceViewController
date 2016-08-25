//
//  RCChartViewPlot.m
//  BubbleChartExample
//
//  Created by Sean Rada on 12/12/13.
//  Copyright (c) 2013 Rigil. All rights reserved.
//

#import "RCChartViewPlot.h"
#import "RCChartView.h"
#import <QuartzCore/QuartzCore.h>

@interface RCChartViewPlot ()

@property (readwrite, nonatomic) NSInteger index;

@end

@implementation RCChartViewPlot {
    RCChartStyle style;
    
    UITapGestureRecognizer *singleTapRecognizer;
    UITapGestureRecognizer *doubleTapRecognizer;
    UILongPressGestureRecognizer *longPressRecognizer;
    
    NSInteger _index;
}

@synthesize delegate;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapRecognizer];
        
        doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed)];
        [self addGestureRecognizer:longPressRecognizer];
        
        [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    }
    return self;
}

- (id)initPlotAtIndex:(NSInteger)index forChartView:(RCChartView *)chartView width:(CGFloat)width {
    self = [super init];
    if (self) {
        //
        style = chartView.chartStyle;
        
        self.index = index;
        
        CGFloat titleHeight = 0;
        if (chartView.displayTitles) {
            titleHeight = 0.0;
        }
        
        CGPoint plotPoint = [chartView.dataSource chartView:chartView pointForPlotWithIndex:index];
        
        CGFloat xRatio = chartView.frame.size.width/[chartView.dataSource chartViewMaxX:chartView];
        CGFloat yRatio = (chartView.frame.size.height - titleHeight)/[chartView.dataSource chartViewMaxY:chartView];
        
        switch (chartView.chartStyle) {
            case RCChartStyleScatter:
            {
                self.frame = CGRectMake(xRatio * plotPoint.x - width/2.0,
                                        ((chartView.frame.size.height - titleHeight) - plotPoint.y * yRatio) - width/2.0,
                                        width, width);
                self.layer.cornerRadius = width/2.0;
                break;
            }
                
            case RCChartStyleBar:
                self.frame = CGRectMake(xRatio * plotPoint.x,
                                        ((chartView.frame.size.height - titleHeight) - plotPoint.y * yRatio),
                                        width,
                                        plotPoint.y * yRatio);
                break;
                
                
            default:
                break;
        }
        
    }
    return self;
}

- (void)singleTapped {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotSingleTapped:atIndex:)])
        [delegate chartViewPlotSingleTapped:self atIndex:self.index];
}

- (void)doubleTapped {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotDoubleTapped:atIndex:)])
        [delegate chartViewPlotDoubleTapped:self atIndex:self.index];
}

- (void)longPressed {
    if (delegate && [delegate respondsToSelector:@selector(chartViewPlotLongPressed:atIndex:)])
        [delegate chartViewPlotLongPressed:self atIndex:self.index];
}


@end

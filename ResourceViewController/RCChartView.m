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
        
        _xAxisTransform = M_PI_4;    // default xAxis transform

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
                titleView.frame = CGRectMake([self cgpointForChartCoordinates:[dataSource chartView:self pointForPlotWithIndex:i]].x + titleView.frame.origin.x,
                                             self.frame.size.height - titlesHeight + titleView.frame.origin.y,
                                             titleView.frame.size.width,
                                             titleView.frame.size.height);
                [self addSubview:titleView];
                
            //Get title from delegate method
            } else if ([dataSource respondsToSelector:@selector(titleForPlotAtIndex:)]) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self cgpointForChartCoordinates:[dataSource chartView:self pointForPlotWithIndex:i]].x - 10.0,
                                                                                self.frame.size.height + titlesWidth*(M_1_PI),
                                                                                titlesWidth,
                                                                                titlesHeight)];
                titleLabel.text = [dataSource titleForPlotAtIndex:i];
                titleLabel.font = titlesFont;
                titleLabel.textColor = titlesColor;
                titleLabel.textAlignment = titleTextAlignment;
                titleLabel.numberOfLines = 0;
                titleLabel.transform = CGAffineTransformMakeRotation(_xAxisTransform);
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


#pragma mark - createYAxisLabelsView


- (UIView*) createYAxisLabelsView:(NSArray*)sortedValues   // JT 16.09.09
{
    int index = 0;
    int numberOfLabels = 5; // default: 5
    CGFloat labelHeight = self.frame.size.height / numberOfLabels; 
    
    UIView *yAxisLabelsContainerView = [[UIView alloc ] initWithFrame:
                                        CGRectMake(0.0, CGRectGetMinY(self.frame),
                                                                                  80.0,
                                                                                  CGRectGetHeight( self.frame))];
    
    for (int i = 0; i < numberOfLabels; ++i)
    {
        UILabel *chartLabel =
        [[UILabel alloc ] initWithFrame: CGRectMake( 0.0 , (labelHeight * (index)) , 75.0, 20.0)];
        
        CGFloat value = (0.0);
        if (i == 0) {
            value = ((NSNumber*)sortedValues[0]).floatValue;
        } else {
            value = ((NSNumber*)sortedValues[0]).floatValue * (numberOfLabels-i) / (CGFloat) numberOfLabels;
            
        }
        chartLabel.textAlignment = NSTextAlignmentRight;
        chartLabel.font =   [UIFont systemFontOfSize:15.0];
        
        // todo use same fonts and colors as the x-axis labels. // JT 16.09.09
        
        chartLabel.text = [self suffixNumber: value];
        [yAxisLabelsContainerView addSubview:chartLabel];
        
        index += 1;
    }
    
    return yAxisLabelsContainerView;
}


- (NSString*) suffixNumber:(CGFloat)num
{
    NSString *sign = ((num < 0) ? @"-" : @"" );
    
    num = fabs(num);
    
    if (num < 1000.0)
    {
        return [NSString stringWithFormat: @"%@%3.1f", sign, num];
    }
    
    int exp = (log10(num) / 3.0 ); //log10(1000));
    
    NSArray *units = @[@"K", @"M", @"G", @"T", @"P", @"E"];
    
    double roundedNum = round(10 * num / pow(1000.0,(double)(exp))) / 10;
    
    return [NSString stringWithFormat: @"%@%.1f%@", sign, roundedNum, units[exp-1]]; //"\(sign)\(roundedNum)\(units[exp-1])";
}


@end

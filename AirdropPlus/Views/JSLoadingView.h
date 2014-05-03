//
//  JSLoadingView.h
//  TurboRoster
//
//  Created by Stone, Jordan Matthew (US - Denver) on 5/3/13.
//  Copyright (c) 2013 Shotdrum Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSLoadingView : UIView

@property (nonatomic, strong) NSString *loadingText;

- (id)initWithLoadingText:(NSString *)text;

- (void)startAnimating;
- (void)stopAnimating;

@end

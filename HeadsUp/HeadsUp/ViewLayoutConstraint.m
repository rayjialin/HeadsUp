//
//  ViewLayoutConstraint.m
//  HeadsUp
//
//  Created by Brian Vo on 2018-05-02.
//  Copyright © 2018 Brian Vo & Ray Lin. All rights reserved.
//

#import "ViewLayoutConstraint.h"

@implementation ViewLayoutConstraint

+(void)viewLayoutConstraint:(UIView *)view defaultView:(UIView *)defaultView {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view.topAnchor constraintEqualToAnchor: defaultView.topAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor: defaultView.bottomAnchor].active = YES;
    [view.leftAnchor constraintEqualToAnchor: defaultView.leftAnchor].active = YES;
    [view.rightAnchor constraintEqualToAnchor: defaultView.rightAnchor].active = YES;
}

@end

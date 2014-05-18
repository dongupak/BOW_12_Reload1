//
//  AppDelegate.h
//  Reload1
//
//  Created by Yeongrok Lee on 11. 8. 22..
//  Copyright Happy Potion 2011년. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

// makeshift classes

@interface SBDisplayItem : UIView 
@property(readonly, assign, nonatomic) NSString* displayIdentifier;
@end

@interface SBAppSwitcherController
- (void)switcherScroller:(id)scroller displayItemWantsToBeRemoved:(SBDisplayItem*)beRemoved;
@end

@interface SBAppSwitcherModel
+ (id)sharedInstance;
- (id)snapshot;
@end

@interface SBDisplayLayout
@property(readonly, assign, nonatomic) NSArray* displayItems;
@end

@interface SBAppSwitcherWindowController
@property(readonly, assign, nonatomic) UIWindow* window;
@end

@interface SBUIController 
+ (id)sharedInstanceIfExists;
@end

// implementation of tweak

UIButton *button; // nasty hack to allow us to remove button
%hook SBAppSwitcherWindowController 
// load our button into view
-(void)_windowDidBecomeVisible:(id)_window {
    UIImage *closeImage = [[UIImage imageNamed:@"/var/mobile/KillSwitcher/close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIWindow *window = MSHookIvar<UIWindow *>(self, "_window");
    UIView *rootView = window.rootViewController.view;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect rect;
    if(orientation == UIInterfaceOrientationPortrait)
        rect = CGRectMake(rootView.frame.size.width - 32,rootView.frame.size.height - 35, 30, 30);
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        rect = CGRectMake(rootView.frame.size.height - 32,rootView.frame.size.width - 35, 30, 30);
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:closeImage forState:UIControlStateNormal];
    [button addTarget:self 
        action:@selector(clearAll)
        forControlEvents:UIControlEventTouchUpInside];
    button.frame = rect;
    button.imageView.tintColor = [UIColor whiteColor];
    [rootView addSubview:button];
return %orig;
}

%new
// method to kill all running apps through switcher
- (void)clearAll {
    id uiController = [%c(SBUIController) sharedInstanceIfExists];
    SBAppSwitcherController *controller = MSHookIvar<SBAppSwitcherController *>(uiController, "_switcherController");
    
    id pageViewController = MSHookIvar<id>(controller, "_pageController");
    
    NSArray *items = [[%c(SBAppSwitcherModel) sharedInstance] snapshot];
    for (SBDisplayLayout *it in items) {
        for (SBDisplayItem *item in it.displayItems) {
            [controller switcherScroller:pageViewController displayItemWantsToBeRemoved:item];
        }
    }
}

%end

%hook SBUIController
// switcher dismissed, remove our button
-(void)animateAppSwitcherDismissalToDisplayLayout:(id)displayLayout withCompletion:(id)completion {
    [button removeFromSuperview];
    %orig;
}
%end

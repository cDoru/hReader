//
//  HRRootViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRRootViewController.h"

#import "HRPatientSummaryViewController.h"
#import "HRTimelineViewController.h"
#import "HRMessagesViewController.h"
#import "HRDoctorsViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRPeoplePickerViewController.h"

#import "SVPanelViewController.h"

static int HRRootViewControllerTitleContext;

@interface HRRootViewController () {
    UISegmentedControl *segmentedControl;
    UILabel *lastUpdatedLabel;
}

@property (nonatomic, strong) UIViewController *visibleViewController;

@end

@implementation HRRootViewController

@synthesize visibleViewController = _visibleViewController;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        // vars
        id controller;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        
        // create child view controllers
        controller = [storyboard instantiateViewControllerWithIdentifier:@"SummaryViewController"];
        [self addChildViewController:controller];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"TimelineViewController"];
        [self addChildViewController:controller];
        controller = [[HRMessagesViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:controller];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"DoctorsViewController"];
        [self addChildViewController:controller];
        
        // register observers
        [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSAssert([obj title], @"Child view controllers must have a title");
            [obj
             addObserver:self
             forKeyPath:@"title"
             options:NSKeyValueObservingOptionNew
             context:&HRRootViewControllerTitleContext];
        }];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"title"];
    }];
}

- (void)setVisibleViewController:(UIViewController *)controller {
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self
     transitionFromViewController:_visibleViewController
     toViewController:controller
     duration:0.0
     options:0
     animations:^{}
     completion:^(BOOL finished) {
         _visibleViewController = controller;
         self.title = _visibleViewController.title;
         [_visibleViewController didMoveToParentViewController:self];
     }];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &HRRootViewControllerTitleContext) {
        UIViewController *controller = (id)object;
        NSUInteger index = [self.childViewControllers indexOfObject:controller];
        [segmentedControl setTitle:controller.title forSegmentAtIndex:index];
        if (controller == self.visibleViewController) {
            self.title = controller.title;
        }
    }
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configure segmented control
    {
        NSArray *titles = [self.childViewControllers valueForKey:@"title"];
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:titles];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.selectedSegmentIndex = 0;
        NSUInteger count = [titles count];
        for (NSUInteger i = 0; i < count; i++) {
            [control setWidth:(600.0 / count) forSegmentAtIndex:i];
        }
        [control addTarget:self action:@selector(segmentSelected) forControlEvents:UIControlEventValueChanged];  
        self.navigationItem.titleView = control;
        segmentedControl = control;
    }
    
    // configure first view
    {
        UIViewController *controller = [self.childViewControllers objectAtIndex:0];
        _visibleViewController = controller;
        self.title = _visibleViewController.title;
        controller.view.frame = self.view.bounds;
        controller.view.frame = self.view.bounds;
        controller.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
    
    
    
    
    
    // configure toolbar
    {
//        UIBarButtonItem *flexible = [[UIBarButtonItem alloc]
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                      target:nil
//                                      action:nil];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0.0, 800.0, 30.0)];
//        label.textAlignment = UITextAlignmentCenter;
//        label.shadowColor = [UIColor whiteColor];
//        label.shadowOffset = CGSizeMake(0.0, 1.0);
//        label.font = [UIFont boldSystemFontOfSize:14.0];
//        label.textColor = [UIColor
//                           colorWithRed:(107.0 / 255.0)
//                           green:(115.0 / 255.0)
//                           blue:(126.0 / 255.0)
//                           alpha:1.0];
//        label.backgroundColor = [UIColor clearColor];
//        UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:label];
//        self.toolbarItems = [NSArray arrayWithObjects:flexible, self.toolsBarButtonItem, self.aboutBarButtonItem, nil];
//        self.lastUpdatedLabel = label;
    }
    
//    self.navigationController.toolbarHidden = YES;
    
    // configure logo
//    {
//        UIImage *logo = [UIImage imageNamed:@"Logo"];
//        UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
//        logoView.frame = CGRectMake(5, 5, 150, 34);
//        UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
//        self.navigationItem.leftBarButtonItem = logoItem;
//    }
    

    
    // add bar button items to right
    /*
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.aboutBarButtonItem, self.toolsBarButtonItem, nil];
    }
     */
    

    
    // set last updated text
//    self.lastUpdatedLabel.text = @"Last Updated: 05 May by Joseph Yang, M.D. (Columbia Pediatric Associates)";

}

- (void)viewDidUnload {
    self.visibleViewController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - button actions

- (void)segmentSelected {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    self.visibleViewController = [self.childViewControllers objectAtIndex:index];
}

- (IBAction)applets:(id)sender {
    UINavigationController *navigation = (id)self.panelViewController.rightAccessoryViewController;
    HRAppletConfigurationViewController *applets = [navigation.viewControllers objectAtIndex:0];
    applets.patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
    applets.tableView.contentOffset = CGPointZero;
    [self.panelViewController exposeRightAccessoryViewController:YES];
}

- (IBAction)people:(id)sender {
    [self.panelViewController exposeLeftAccessoryViewController:YES];
}
     
@end

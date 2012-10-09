//
//  HRPatientSummarySplitViewController.m
//  HReader
//
//  Created by Marshall Huss on 11/30/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRPatientSummaryViewController.h"
#import "HRRootViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRPeoplePickerViewController.h"
#import "HRAppletTile.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"
#import "HRMEntry.h"

#import "NSString+SentenceCapitalization.h"

#import "SVPanelViewController.h"

@interface HRPatientSummaryViewController () {
@private
    NSArray * __strong __gridViews;
}

- (void)reloadData;

@end

@implementation HRPatientSummaryViewController

@synthesize gridView                            = __gridView;
@synthesize headerView                          = __headerView;

@synthesize patientNameLabel                    = __patientNameLabel;
@synthesize dateOfBirthLabel                    = __dateOfBirthLabel;
@synthesize dateOfBirthTitleLabel               = __dateOfBirthTitleLabel;
@synthesize allergiesLabel                      = __allergiesLabel;
@synthesize patientImageView                    = __patientImageView;

@synthesize conditionsContainerView             = __conditionsContainerView;
@synthesize conditionDateLabels                 = __conditionDateLabels;
@synthesize conditionNameLabels                 = __conditionNameLabels;

@synthesize eventsContainerView                 = __eventsContainerView;
@synthesize followUpAppointmentNameLabel        = __followUpAppointmentNameLabel;
@synthesize followUpAppointmentDateLabel        = __followUpAppointmentDateLabel;
@synthesize medicationRefillNameLabel           = __medicationRefillNameLabel;
@synthesize medicationRefillDateLabel           = __medicationRefillDateLabel;
@synthesize planOfCareLabel                     = __planOfCareLabel;








@synthesize functionalStatusDateLabel           = __functionalStatusDateLabel;
@synthesize functionalStatusTypeLabel           = __functionalStatusTypeLabel;
@synthesize functionalStatusProblemLabel        = __functionalStatusProblemLabel;
@synthesize functionalStatusStatusLabel         = __functionalStatusStatusLabel;
@synthesize pulseLabel                          = __pulseLabel;
@synthesize pulseDateLabel                      = __pulseDate;
@synthesize pulseNormalLabel                    = __pulseNormalLabel;
@synthesize advanceDirectivesLabel              = __advanceDirectivesLabel;
@synthesize diagnosisLabel                      = __diagnosisLabel;
@synthesize diagnosisDateLabel                  = __diagnosisDateLabel;
@synthesize pulseImageView                      = __pulseImageView;

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Summary";
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(reloadData)
         name:NSManagedObjectContextDidSaveNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(reloadData)
         name:HRPatientDidChangeNotification
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSManagedObjectContextDidSaveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:HRPatientDidChangeNotification
     object:nil];
}

- (void)reloadData {
    if ([self isViewLoaded]) {
        
        // get patient
        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
        NSDictionary *syntheticInfo = patient.syntheticInfo;
        self.patientImageView.image = [patient patientImage];
        
        // date of birth
        self.patientNameLabel.text = [[patient compositeName] uppercaseString];
        if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB:"]) {
            self.dateOfBirthLabel.text = [patient.dateOfBirth hr_mediumStyleDate];
        }
        else {
            self.dateOfBirthLabel.text = [patient.dateOfBirth hr_ageString];
        }
        
        // allergies
        {
            NSArray *allergies = [patient.syntheticInfo objectForKey:@"allergies"];
            NSUInteger count = [allergies count];
            self.allergiesLabel.textColor = [UIColor blackColor];
            if (count) {
                NSMutableString *string = [[allergies objectAtIndex:0] mutableCopy];
                if (count > 1) {
                    self.allergiesLabel.textColor = [UIColor hr_redColor];
                    [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
                }
                if ([string length] > 0) {
                    self.allergiesLabel.textColor = [UIColor hr_redColor];
                    self.allergiesLabel.text = string;
                }
                else {
                    self.allergiesLabel.text = @"None";
                }
            }
            else { self.allergiesLabel.text = @"None"; }
        }
        
        // conditions
        {
            NSArray *conditions = [patient conditions];
            NSArray *nameLabels = [self.conditionNameLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
            NSArray *dateLabels = [self.conditionDateLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
            NSUInteger conditionsCount = [conditions count];
            NSUInteger labelCount = [nameLabels count];
            BOOL showCountLabel = (conditionsCount > labelCount);
            NSAssert(labelCount == [dateLabels count], @"There must be an equal number of name and date labels");
            [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
                
                // this is the last label and we should show count
                if (index == labelCount - 1 && showCountLabel) {
                    label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(conditionsCount - labelCount + 1)];
                }
                
                // normal condition label
                else if (index < conditionsCount) {
                    HRMEntry *condition = [conditions objectAtIndex:index];
                    label.text = [condition.desc sentenceCapitalizedString];
                }
                
                // no conditions
                else if (index == 0) { label.text = @"None"; }
                
                // clear the label
                else { label.text = nil; }
                
            }];
            [dateLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
                if (index == labelCount - 1 && showCountLabel) {
                    label.text = nil;
                }
                else if (index < conditionsCount) {
                    HRMEntry *condition = [conditions objectAtIndex:index];
                    label.text = [condition.startDate hr_mediumStyleDate];
                }
                else { label.text = nil; }
            }];
        }
        
        // events
        {
            NSDictionary *event = [[syntheticInfo objectForKey:@"upcoming_events"] lastObject];
            NSString *name = [[event objectForKey:@"title"] sentenceCapitalizedString];
            if (name) {
                self.followUpAppointmentNameLabel.text = name;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"follow_up_appointment_date"] doubleValue]];
                self.followUpAppointmentDateLabel.text = ([date hr_mediumStyleDate]) ?: nil;
            }
            else {
                self.followUpAppointmentDateLabel.text = nil;
                self.followUpAppointmentNameLabel.text = @"None";
            }
            NSString *care = [[[event objectForKey:@"plan_of_care"] lastObject] sentenceCapitalizedString];
            self.planOfCareLabel.text = (care) ?: @"None";
            NSDictionary *medication = [[event objectForKey:@"medication_refill"] lastObject];
            if (medication) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[medication objectForKey:@"date"] doubleValue]];
                self.medicationRefillDateLabel.text = [date hr_mediumStyleDate];
                self.medicationRefillNameLabel.text = [[medication objectForKey:@"medication"] sentenceCapitalizedString];
            }
            else {
                self.medicationRefillNameLabel.text = @"None";
                self.medicationRefillDateLabel.text = nil;
            }
        }
        
        // applets
        {
            NSMutableArray *views = [NSMutableArray array];
            NSArray *identifiers = patient.applets;
            NSString *token = patient.identityToken;
            [identifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *applet = [[HRAppletConfigurationViewController appletWithIdentifier:obj] mutableCopy];
                [applet setObject:token forKey:HRAppletTilePatientIdentityTokenKey];
                if ([obj rangeOfString:@"org.mitre.hreader"].location == 0) {
                    [applet setObject:patient forKey:@"__private_patient__"];
                }
                if (applet) {
                    Class c = NSClassFromString([applet objectForKey:@"class_name"]);
                    [views addObject:[c tileWithUserInfo:applet]];
                }
                else { NSLog(@"Unable to load applet with identifier %@", obj); }
            }];
            __gridViews = views;
            [self.gridView reloadData];
            
        }
        
        /*
         {
         NSArray *allergies = patient.allergies;
         NSUInteger count = [allergies count];
         //    self.allergiesLabel.textColor = [HRConfig redColor];
         if (count) {
         NSMutableString *string = [[[allergies objectAtIndex:0] desc] mutableCopy];
         if (count > 1) {
         [string appendFormat:@", %lu more", (unsigned long)(count - 1)];
         }
         if ([string length] > 0) {
         self.allergiesLabel.text = string;
         }
         else {
         self.allergiesLabel.text = @"None";
         }
         }
         else { self.allergiesLabel.text = @"None"; }
         }
         */
        

        

        
        {
            
            /*
             
             // upcoming events
             
             
             // functional status
             NSDictionary *functionalStatus = [syntheticInfo objectForKey:@"functional_status"];
             self.functionalStatusDateLabel.text = [self formattedDate:[[functionalStatus objectForKey:@"date"] doubleValue]];
             self.functionalStatusProblemLabel.text = [functionalStatus objectForKey:@"problem"];
             self.functionalStatusStatusLabel.text = [functionalStatus objectForKey:@"status"];
             self.functionalStatusTypeLabel.text = [functionalStatus objectForKey:@"type"];;
             
             // advanced directives
             self.advanceDirectivesLabel.text = [syntheticInfo objectForKey:@"advanced_directives"];
             
             // diagnosis
             NSDictionary *diagnosis = [syntheticInfo objectForKey:@"diagnosis"];
             self.diagnosisDateLabel.text = [self formattedDate:[[diagnosis objectForKey:@"results"] doubleValue]];
             self.diagnosisLabel.text = [diagnosis objectForKey:@"results"];
             
             */
            
            
            
            
            
            
        }
        
        /*
         {
         HRPatient *patient = [HRConfig selectedPatient];
         self.recentConditionsLabel.text = [patient.info objectForKey:@"recent_condition"];
         self.recentConditionsDateLabel.text = [patient.info objectForKey:@"recent_condition_date"];
         self.chronicConditionsLabel.text = [[patient.info objectForKey:@"chronic_conditions"] componentsJoinedByString:@"\n"];
         self.upcomingEventsLabel.text = [patient.info objectForKey:@"upcoming_events"];
         self.planOfCareLabel.text = [patient.info objectForKey:@"plan_of_care"];
         self.followUpAppointmentLabel.text = [patient.info objectForKey:@"follow_up_appointment"];
         self.medicationRefillLabel.text = [patient.info objectForKey:@"medication_refill"];
         
         
         self.pulseLabel.text = [patient.info objectForKey:@"pulse"];
         self.pulseDateLabel.text = [patient.info objectForKey:@"pulse_date"];
         self.pulseNormalLabel.text = [patient.info objectForKey:@"pulse_normal"];
         self.functionalStatusDateLabel.text = [patient.info objectForKey:@"functional_status_date"];
         self.functionalStatusProblemLabel.text = [patient.info objectForKey:@"functional_status_problem"];
         self.functionalStatusStatusLabel.text = [patient.info objectForKey:@"functional_status_status"];
         self.functionalStatusTypeLabel.text = [patient.info objectForKey:@"functional_status_type"];
         self.diagnosisLabel.text = [patient.info objectForKey:@"diagnosis_results"];
         self.diagnosisDateLabel.text = [patient.info objectForKey:@"diagnosis_date"];
         self.pulseImageView.image = [patient.info objectForKey:@"pulse_sparklines"];
         
         }
         */
        
    }
}

- (void)appletConfigurationDidChange {
    [self reloadData];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // header shadow view
    CALayer *layer = self.headerView.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    [self.view bringSubviewToFront:self.headerView];
    
    // image shadow
    layer = self.patientImageView.superview.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.35;
    layer.shadowOffset = CGSizeMake(0.0, 1.0);
    layer.shadowRadius = 5.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // date of birth tap
    NSArray *array = [NSArray arrayWithObjects:self.dateOfBirthLabel, self.dateOfBirthTitleLabel, nil];
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(toggleDateOfBirth:)];
        [view addGestureRecognizer:gesture];
    }];
    
    
    // gestures
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(patientImageViewTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self.patientImageView.superview addGestureRecognizer:gesture];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(conditionsContainerViewTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self.conditionsContainerView addGestureRecognizer:gesture];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(eventsContainerViewTap:)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [self.eventsContainerView addGestureRecognizer:gesture];
    }
    
}

- (void)viewDidUnload {
    
    self.headerView = nil;
    self.gridView = nil;

    self.patientNameLabel = nil;
    self.dateOfBirthTitleLabel = nil;
    self.dateOfBirthLabel = nil;
    self.allergiesLabel = nil;
    self.patientImageView = nil;
    
    self.conditionsContainerView = nil;
    self.conditionDateLabels = nil;
    self.conditionNameLabels = nil;
    
    self.eventsContainerView = nil;
    self.followUpAppointmentDateLabel = nil;
    self.followUpAppointmentNameLabel = nil;
    self.planOfCareLabel = nil;
    self.medicationRefillNameLabel = nil;
    self.medicationRefillDateLabel = nil;
    
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - grid view delegate

- (NSUInteger)numberOfViewsInGridView:(HRGridTableView *)gridView {
    return [__gridViews count];
}

- (UIView *)gridView:(HRGridTableView *)gridView viewAtIndex:(NSUInteger)index {
    return [__gridViews objectAtIndex:index];
}

- (void)gridView:(HRGridTableView *)gridView didSelectViewAtIndex:(NSUInteger)index {
    HRAppletTile *tile = [__gridViews objectAtIndex:index];
    CGRect rect = [self.view convertRect:tile.bounds fromView:tile];
    [tile didReceiveTap:self inRect:rect];
}

#pragma mark - gestures

- (void)toggleDateOfBirth:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if ([self.dateOfBirthTitleLabel.text isEqualToString:@"DOB:"]) {
            self.dateOfBirthTitleLabel.text = @"AGE:";
        }
        else {
            self.dateOfBirthTitleLabel.text = @"DOB:";
        }
        [self reloadData];
    }
}

- (void)conditionsContainerViewTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
        NSString *imageName = [NSString stringWithFormat:@"%@-condition-full", [patient initials]];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            UIViewController *controller = [[UIViewController alloc] init];
            controller.title = @"Conditions";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = controller.view.bounds;
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            [controller.view addSubview:imageView];
            [self.navigationController pushViewController:controller animated:YES];   
        }
    }
}

- (void)eventsContainerViewTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        HRMPatient *patient = [(id)self.panelViewController.leftAccessoryViewController selectedPatient];
        NSString *imageName = [NSString stringWithFormat:@"%@-events-full", [patient initials]];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            UIViewController *controller = [[UIViewController alloc] init];
            controller.title = @"Recent Events";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = controller.view.bounds;
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            [controller.view addSubview:imageView];
            [self.navigationController pushViewController:controller animated:YES];   
        }
    }
}

- (void)patientImageViewTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        HRPeoplePickerViewController *picker = (id)self.panelViewController.leftAccessoryViewController;
        [picker selectNextPatient];
    }
}

#pragma mark - private

- (NSString *)formattedDate:(double)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [date hr_mediumStyleDate];
}

@end

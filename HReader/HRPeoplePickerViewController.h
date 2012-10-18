//
//  HRPeoplePickerViewController.h
//  HReader
//
//  Created by Caleb Davenport on 4/18/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/*
 
 Dispatched to let interested objects know that the selected patient has
 changed. This will be sent on the main thread.
 
 */
extern NSString * const HRSelectedPatientDidChangeNotification;

/*
 
 Fetch the selected patient from the `userInfo` of
 `HRPatientDidChangeNotification`. This object will be fetched from the main
 application managed object context.
 
 */
extern NSString * const HRSelectedPatientKey;

@class HRMPatient;

@interface HRPeoplePickerViewController : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
NSFetchedResultsControllerDelegate,
UISearchDisplayDelegate,
UISearchBarDelegate>

// user interface
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

/*
 
 Present the view that allows the user to add and remove patients.
 
 */
- (IBAction)showManageFamilyInterface:(id)sender;

/*
 
 Get the selected patient from the people picker. This object will be pulled
 from the main application managed object context.
 
 */
- (HRMPatient *)selectedPatient;

/*
 
 Toggle the selected patient to the next one in the people picker list. In the
 event of an overflow, the selection will wrap around to the beginning of the
 list.
 
 */
- (void)selectNextPatient;

/*
 
 Toggle the selected patient to the previous one in the people picker list. In
 the event of an overflow, the selection will wrap around to the end of the
 list.
 
 */
- (void)selectPreviousPatient;

@end

//
//  HRMedicationsMasterViewController.m
//  HReader
//
//  Created by DiCristofaro, Lauren M on 11/13/12.
//  Copyright (c) 2012 MITRE Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HRMedicationsMasterViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRPeoplePickerViewController.h"
#import "HRAppletTile.h"
#import "HRAppDelegate.h"
#import "HRMPatient.h"
#import "HRMEntry.h"
#import "HRPanelViewController.h"
#import "HRMedicationCell.h"
#import "HRPeoplePickerViewController_private.h"

#import "NSString+SentenceCapitalization.h"

@implementation HRMedicationsMasterViewController {
    id _keyboardWillShowObserver;
    id _keyboardWillHideObserver;
}

#pragma mark - object methods

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.title = @"Medications";
        
        //add keyboard show observer
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        __weak HRMedicationsMasterViewController *weakSelf = self;
        [center
         addObserverForName:UIKeyboardWillShowNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             HRMedicationsMasterViewController *strongSelf = weakSelf;
             if (strongSelf) {
                 [strongSelf keyboardWillShow:notification];
             }
         }];
        
        //add keyboard hide observer
        [center
         addObserverForName:UIKeyboardWillHideNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             HRMedicationsMasterViewController *strongSelf = weakSelf;
             if (strongSelf) {
                 [strongSelf keyboardWillHide:notification];
             }
         }];
        
        //add data
        //[self initializeData];
    }
    return self;
}


- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center
     removeObserver:_keyboardWillHideObserver
     name:UIKeyboardWillHideNotification
     object:nil];
    [center
     removeObserver:_keyboardWillShowObserver
     name:UIKeyboardWillShowNotification
     object:nil];
}


- (void)reloadWithPatient:(HRMPatient *)patient {
    
    NSLog(@"Reloading with patient");
    
    //hide header edit buttons
    [self.currentMedicationsEditButton setHidden:YES];
    [self.upcomingRefillsEditButton setHidden:YES];
    
    // synthetic info
    NSDictionary *syntheticInfo = patient.syntheticInfo;
    
    // medications
    {
        NSArray *medications = [patient medications];
//        NSArray *foundMedications = [patient medications];
//        NSMutableArray *medications = [NSMutableArray arrayWithCapacity:[foundMedications count]];
//        //remove user-deleted medications
//        for(HRMEntry *med in foundMedications){
//            if(!med.userDeleted.boolValue){
//                [medications addObject:med];
//            }
//        }
        
        NSArray *nameLabels = [self.medicationNameLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSArray *dosageLabels = [self.medicationDosageLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSUInteger medicationsCount = [medications count];
        NSUInteger labelCount = [nameLabels count];
        BOOL showCountLabel = (medicationsCount > labelCount);
        NSAssert(labelCount == [dosageLabels count], @"There must be an equal number of name and dosage labels");
        [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            
            // this is the last label and we should show count
            if (index == labelCount - 1 && showCountLabel) {
                label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
            }
            
            // normal medication label
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                [label setAttributedText:[medication getDescAttributeString]];
                //label.text = [medication.desc sentenceCapitalizedString];
            }
            
            // no medications
            else if (index == 0) { label.text = @"None"; }
            
            // clear the label
            else { label.text = nil; }
            
        }];
        [dosageLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            if (index == labelCount - 1 && showCountLabel) {
                label.text = nil;
            }
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                //TODO: LMD- currently dosage is just empty string
                //figure out how dose dictionary works (find key)
                //label.text = [medication.dose objectForKey:@""];
                label.text = nil;
            }
            else { label.text = nil; }
        }];
    }
    
    //refills
    {
        NSArray *medications = [patient medications];
//        NSArray *foundMedications = [patient medications];
//        NSMutableArray *medications = [NSMutableArray arrayWithCapacity:[foundMedications count]];
//        //remove user-deleted medications
//        for(HRMEntry *med in foundMedications){
//            if(!med.userDeleted.boolValue){
//                [medications addObject:med];
//            }
//        }
        NSArray *nameLabels = [self.medicationRefillLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSArray *locationLabels = [self.refillLocationLabels hr_sortedArrayUsingKey:@"tag" ascending:YES];
        NSUInteger medicationsCount = [medications count];
        NSUInteger labelCount = [nameLabels count];
        BOOL showCountLabel = (medicationsCount > labelCount);
        NSAssert(labelCount == [locationLabels count], @"There must be an equal number of name and location labels");
        [nameLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            
            // this is the last label and we should show count
            if (index == labelCount - 1 && showCountLabel) {
                label.text = [NSString stringWithFormat:@"%lu more…", (unsigned long)(medicationsCount - labelCount + 1)];
            }
            
            // normal medication label
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                
                [label setAttributedText:[medication getDescAttributeString]];
                //label.text = [medication.desc sentenceCapitalizedString];
            }
            
            // no medications
            else if (index == 0) { label.text = @"None"; }
            
            // clear the label
            else { label.text = nil; }
            
        }];
        [locationLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger index, BOOL *stop) {
            if (index == labelCount - 1 && showCountLabel) {
                label.text = nil;
            }
            else if (index < medicationsCount) {
                HRMEntry *medication = [medications objectAtIndex:index];
                //TODO: LMD- currently location is just empty string
                //figure out how refill information works
                //label.text = [medication.? objectForKey:@""];
                label.text = nil;
            }
            else { label.text = nil; }
        }];
    }
    
        
    // Medication details
    {
        //add data

        [self initializeDatawithPatient:patient];
        [self.collectionView reloadData];
    }
    
    // applets

}

- (void)appletConfigurationDidChange {
    [self reloadData];
}

#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - collection view

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    HRMedicationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MedicationCellReuseID" forIndexPath:indexPath];
    
    [cell setMedication:[self.medicationList objectAtIndex:indexPath.item]];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.medicationList count];
}

#pragma mark - gestures



- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] doubleValue];
    [UIView
     animateWithDuration:duration
     delay:0.0
     options:options
     animations:^{
//         CGRect keyboardEndFrame;
//         [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
//         
//         NSLog(@"keyboard frame end values: %f, %f", keyboardEndFrame.size.height, keyboardEndFrame.size.width);
         
         //to move header view up by the headerView's height
         CGFloat newHeaderOriginY = self.headerView.frame.origin.y -
                                               self.headerView.frame.size.height;
         //to move collection view up by the headerView's height
         CGFloat newCollectionOriginY = self.collectionView.frame.origin.y -
                                                   self.headerView.frame.size.height;
         self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                            newHeaderOriginY,
                                            self.headerView.frame.size.width,
                                            self.headerView.frame.size.height);
         self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                            newCollectionOriginY,
                                            self.collectionView.frame.size.width,
                                            self.collectionView.frame.size.height);
         
     }
     completion:^(BOOL finished) {
         
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger options = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] doubleValue];
    [UIView
     animateWithDuration:duration
     delay:0.0
     options:options
     animations:^{
//         CGRect keyboardEndFrame;
//         [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
         
         //to move header view down by the headerView's height
         CGFloat newHeaderOriginY = self.headerView.frame.origin.y +
         self.headerView.frame.size.height;
         //to move collection view down by the headerView's height
         CGFloat newCollectionOriginY = self.collectionView.frame.origin.y +
         self.headerView.frame.size.height;
         self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                            newHeaderOriginY,
                                            self.headerView.frame.size.width,
                                            self.headerView.frame.size.height);
         self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                                newCollectionOriginY,
                                                self.collectionView.frame.size.width,
                                                self.collectionView.frame.size.height);
         //[self reloadInputViews];
         
     }
     completion:^(BOOL finished) {
         
     }];
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setRefillLocationLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setMedicationRefillLabels:nil];
    [self setCurrentMedicationsEditButton:nil];
    [self setUpcomingRefillsEditButton:nil];
    [super viewDidUnload];
}

- (void)initializeDatawithPatient:(HRMPatient *)currentPatient{
    NSLog(@"Initializing data");
    self.medicationList = [currentPatient medications];
    
    for(NSUInteger i=0;i<self.medicationList.count;i++){
        HRMEntry *med = [self.medicationList objectAtIndex:i];
        if(med.comments == nil){
            med.comments = @"-";
            
            NSManagedObjectContext *context = [med managedObjectContext];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        if(med.patientComments == nil){
            NSLog(@"patient comments for entry %d are nil, setting to dashes", i);
            //default dose comment from entry's dose information
            NSString *doseString = @"-";
            //TODO: LMD how to get/properly format dose information?
            if(med.dose.description != nil){
                doseString = med.dose.description;
            }
            
            NSArray *keys = [NSArray arrayWithObjects:QUANTITY_KEY, DOSE_KEY, DIRECTIONS_KEY, PRESCRIBER_KEY, nil];
            NSArray *objects = [NSArray arrayWithObjects:@"-", doseString, @"-", @"-", nil];
            [med setPatientComments:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            
            NSManagedObjectContext *context = [med managedObjectContext];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
    }
    
}
- (IBAction)upcomingRefillsEdit:(id)sender {
    if (self.editing) {
        //received "save button" click
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        NSString *editImageFile = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [sender setImage:editImage forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        //received "edit button" click
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        NSString *saveImageFile = [[NSBundle mainBundle] pathForResource:@"save" ofType:@"png"];
        UIImage *saveImage = [UIImage imageWithContentsOfFile:saveImageFile];
        [sender setImage:saveImage forState:UIControlStateNormal];
        
        [self setEditing:YES animated:YES];
    }
}

- (IBAction)currentMedicationsEdit:(id)sender {
    if (self.editing) {
        //received "save button" click
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        NSString *editImageFile = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [sender setImage:editImage forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        //received "edit button" click
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        NSString *saveImageFile = [[NSBundle mainBundle] pathForResource:@"save" ofType:@"png"];
        UIImage *saveImage = [UIImage imageWithContentsOfFile:saveImageFile];
        [sender setImage:saveImage forState:UIControlStateNormal];
        
        [self setEditing:YES animated:YES];
    }
}

- (IBAction)setEditMode:(UIButton *)sender {
    
    if (self.editing) {
        //received "save button" click
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        NSString *editImageFile = [[NSBundle mainBundle] pathForResource:@"edit" ofType:@"png"];
        UIImage *editImage = [UIImage imageWithContentsOfFile:editImageFile];
        [sender setImage:editImage forState:UIControlStateNormal];
        
        [self setEditing:NO animated:YES];
    } else {
        //received "edit button" click
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        NSString *saveImageFile = [[NSBundle mainBundle] pathForResource:@"save" ofType:@"png"];
        UIImage *saveImage = [UIImage imageWithContentsOfFile:saveImageFile];
        [sender setImage:saveImage forState:UIControlStateNormal];
        
        [self setEditing:YES animated:YES];
    }
    
    
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    self.editing = flag;
    
    if (flag == YES){
        // Change views to edit mode.
    }
    else {
        //change views to noneditable
        
        
        //set managed object fields from text fields
        
        
        //save data
        
    }
}

- (void) setEditStyleForTextView:(UITextView *)textView{
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [[UIColor grayColor] CGColor];
    textView.layer.cornerRadius = 5;
    [textView setEditable:YES];
}

- (void) finishEditForTextView:(UITextView *)textView{
    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [textView setEditable:NO];
}

@end

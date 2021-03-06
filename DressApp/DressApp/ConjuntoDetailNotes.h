//
//  ConjuntoDetailNotes.h
//  DressApp
//
//  Created by Javier Sanchez Sierra on 12/1/11.
//  Copyright (c) 2011 Javier Sanchez Sierra. All rights reserved.
//
// This file is part of DressApp.

// DressApp is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// DressApp is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//
// Permission is hereby granted, free of charge, to any person obtaining 
// a copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation the 
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
// sell copies of the Software, and to permit persons to whom the Software is furnished 
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//https://github.com/jsanchezsierra/DressApp


#import <UIKit/UIKit.h>
#import "Conjunto.h"
#import "CalendarForConjuntoVC.h"

@protocol ConjuntoDetailNotesVCDelegate;

@interface ConjuntoDetailNotes : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,CalendarForConjuntoVCDelegate>
{
    NSInteger currentCategoriaIndex;
    NSInteger rowHeight;
    BOOL saveBeforeExit;
}

@property (nonatomic, assign) id <ConjuntoDetailNotesVCDelegate> delegate;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Conjunto *conjunto;

@property (nonatomic, strong) IBOutlet UITableView *notesTableView;
@property (nonatomic, strong) IBOutlet UINavigationItem *myNavigationTitle;
@property (nonatomic, strong) IBOutlet UINavigationBar *myNavigationBar;
@property (nonatomic, strong) IBOutlet UITextField *myTextField;
@property (nonatomic, strong) IBOutlet UIImageView *myMainFrame;
@property (nonatomic, strong) IBOutlet UIImageView *myImageViewBackground;
@property (nonatomic, strong) IBOutlet UIImageView *myNotesImageViewFrame;
@property (nonatomic, strong) IBOutlet UILabel *notesTitle;
@property (nonatomic, strong) IBOutlet UILabel *fechaTitle;
@property (nonatomic, strong) IBOutlet UIButton *calendarDateBtn;

-(IBAction) doneButton;
-(void) openCalendarViewController;

@end

@protocol ConjuntoDetailNotesVCDelegate
- (void) dismissConjuntoDetailNotesVCDelegate;
@end
//
//  CalendarForConjuntoVC.m
//  DressApp
//
//  Created by Javier Sanchez Sierra on 11/21/11.
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


#import "CalendarForConjuntoVC.h"
#import "CalendarConjunto.h"
#import "StyleDressApp.h"

@implementation CalendarForConjuntoVC
@synthesize managedObjectContext;
@synthesize delegate,isRight;
@synthesize containerView;
@synthesize scrollView,viewControllers,currentPage;
@synthesize selectedDate;
@synthesize myViewActivity;
@synthesize isChoosingCalendarForConjunto;
 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [self viewInitCalendar];
     [[self.viewControllers objectAtIndex:currentPage] drawCalendar]; 
    [super viewDidLoad];
}

 

-(void) viewInitCalendar
{
    [self.navigationController.navigationBar setTintColor:[ StyleDressApp colorWithStyleForObject:StyleColorMainNavigationBar] ];

    [self.view setBackgroundColor:[StyleDressApp colorWithStyleForObject:StyleColorCalendarBackground]];
    [self.scrollView setBackgroundColor:[StyleDressApp colorWithStyleForObject:StyleColorCalendarBackground]];
        
        //The view Controller is not in Right position
        isRight=NO;
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelection)]; 

        self.navigationItem.leftBarButtonItem = leftBarButtonItem; 
        
        
        //Create LeftBarButtonItem -  MenuButton
        UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hoy", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goToToday)];
        self.navigationItem.rightBarButtonItem= todayButton; 
        
        
        //Prepare file manager && cachesDirectory
        cachesDirectory= [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
        fileManager = [NSFileManager defaultManager];
        
        currentPage=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentMonth"] intValue]-1;
        numberOfPages= 12;
        
        // view controllers are created lazily
        // in the meantime, load the array with placeholders which will be replaced on demand
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < numberOfPages; i++)
        {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;
        
        
        // a page is the width of the scroll view
        scrollView.pagingEnabled = YES;
        scrollView.frame=CGRectMake(0,0,320,416);
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, 416);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delegate = self;
        
    [self performSelector:@selector(loadUnloadViews)];

        [scrollView setContentOffset:CGPointMake( scrollView.frame.size.width * currentPage, 0)];
        
        //allowScrollViewDidEndDecelerating=YES;
        checkScrollXPosition=YES;
        
}


-(void) cancelSelection
{
    [self.delegate calendarDidCancelSelection];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

 
 

#pragma mark - Navigation Controls methods

-(void) previousMonthAnimated:(BOOL)isAnimated

{
    currentPage--;
    if (currentPage<0) 
    {
        currentPage=11;
        
        //Actualizo el año cuando llega a Enero
        NSInteger tempCurrentYear=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentYear"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempCurrentYear-1] forKey:@"calendarCurrentYear"];
        [self unloadAllViews];
    }
    
    //Muevo ScrollView a nueva posicion
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * currentPage, 0) animated:isAnimated];
}


-(void) nextMonthAnimated:(BOOL)isAnimated
{
    
    currentPage++;
    
    if (currentPage>=12) 
    {
        currentPage=0;
        
        //Actualizo el año cuando llega a Diciembre
        NSInteger tempCurrentYear=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentYear"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempCurrentYear+1] forKey:@"calendarCurrentYear"];
        [self unloadAllViews];
    }
    
    //Muevo ScrollView a nueva posicion
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * currentPage, 0) animated:isAnimated];
    
}

-(void) goToToday
{
    
    //SET TODAY DATE TO CALENDER MONTH & YEAR
    NSCalendar *myCalendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsToday=[[NSDateComponents alloc] init];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    compsToday= [myCalendar components:unitFlags fromDate:[NSDate date]];
    NSInteger newMonth= [compsToday month];
    NSInteger newYear= [compsToday year];
    NSInteger newDay= [compsToday day];
    
    NSInteger thisMonth=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentMonth"] intValue];
    NSInteger thisYear=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentYear"] intValue];
    
    
    //Si no estoy en el mes actual, hago un scrool hasta el mes actual
    //Check if the current year is equal
    if (newYear!=thisYear || newMonth!=thisMonth) 
    {
 
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newMonth] forKey:@"calendarCurrentMonth"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newYear] forKey:@"calendarCurrentYear"];
        
        currentPage=newMonth-1;
        
        [self unloadAllViews];
        
        //Muevo ScrollView a nueva posicion
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * currentPage, 0) animated:YES];
        
    
    }
       
    NSDateComponents *compsForToday = [[NSDateComponents alloc] init];
    [compsForToday setDay:newDay];
    [compsForToday setMonth:newMonth];
    [compsForToday setYear:newYear];
    [compsForToday setHour:20];
    [compsForToday setMinute:00];
    NSDate *todayDate =[myCalendar dateFromComponents:compsForToday];

    
    //COMPRUEBO SI YA HAY ALGO PARA HOY Y SI HAY ALGO LO EDITO, SI NO LO CREO
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"CalendarConjunto" inManagedObjectContext:self.managedObjectContext];
    
    if ( [ [ [NSUserDefaults standardUserDefaults] objectForKey:@"userToCheck" ] isEqualToString:@"LOGGEDUSER_ONLY"]) 
        request.predicate = [NSPredicate predicateWithFormat:@" (fecha == %@) AND (usuario == %@)",todayDate,[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]  ];
    else if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"userToCheck"] isEqualToString:@"LOGGEDUSER_AND_DEFAULT"]) 
        request.predicate = [NSPredicate predicateWithFormat:@" (fecha == %@) AND ((usuario == %@) OR (usuario == %@) OR (usuario == %@)  )",todayDate,[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],DRESSAPP_DEFAULT_USER,[[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"]  ];

	
    NSError *error = nil;
    NSArray *fetchResults= [self.managedObjectContext executeFetchRequest:request error:&error] ;
    if ([fetchResults count]==0)  //crea item a fecha actual 
        [self calendarCreateNewEntryForDay:todayDate];
    else   //Open Calendar Details
        [self calendarEditEntryForDay:todayDate];
}

#pragma mark - UIScrollViewDelegate methods


-(void) scrollViewDidScroll:(UIScrollView *)thisScrollView
{
    
    CGFloat pageWidth = thisScrollView.frame.size.width;
    int page = floor((thisScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //Si estoy en diciembre y voy hacia la derecha, pasa al año siguiente
    if (thisScrollView.contentOffset.x > 3620 && checkScrollXPosition==YES) //3520 
    {
        //Actualizo el año cuando llega a Diciembre
        NSInteger tempCurrentYear=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentYear"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempCurrentYear+1] forKey:@"calendarCurrentYear"];
        checkScrollXPosition=NO;
        [self unloadAllViews];
        [thisScrollView  setContentOffset:CGPointMake(-80,0)] ;
    }
    
    //Si estoy en enero y voy hacia la izquierda, pasa al año anterior
    if (thisScrollView.contentOffset.x < -100 && checkScrollXPosition==YES) 
    {
        //Actualizo el año cuando llega a Diciembre
        NSInteger tempCurrentYear=  [[[NSUserDefaults standardUserDefaults] objectForKey:@"calendarCurrentYear"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempCurrentYear-1] forKey:@"calendarCurrentYear"];
        checkScrollXPosition=NO;
        [self unloadAllViews];
        [thisScrollView  setContentOffset:CGPointMake(3600,0)] ;
    }
    
    //change UIActivityIndicatorView frame position 
    self.myViewActivity.frame=CGRectMake(pageWidth*page + pageWidth/2,170, 20,20);
    [myViewActivity startAnimating];
    
}


//Se ejecuta cuando acaba "scrollView setContentOffset" de previousMonth-nextMonth
-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(currentPage+1)] forKey:@"calendarCurrentMonth"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCalendarActivityIndicators" object:self];
    
    //load and unload new Views
    [self performSelector:@selector(loadUnloadViews) withObject:nil afterDelay:0.1];
 }


- (void)scrollViewDidEndDecelerating:(UIScrollView *)thisScrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page < 0 || page >= numberOfPages)
        return;
    
    currentPage=page;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(currentPage+1)] forKey:@"calendarCurrentMonth"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCalendarActivityIndicators" object:self];
    
    //load and unload new Views
    [self performSelector:@selector(loadUnloadViews) withObject:nil afterDelay:0.1];
    
    
}

-(void) loadUnloadViews
{
    
    [self performSelectorOnMainThread:@selector(loadUnloadViewsWaitingUntilDone) withObject:nil waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopCalendarActivityIndicators" object:self];
    checkScrollXPosition=YES;
}

-(void) loadUnloadViewsWaitingUntilDone
{
    [self unLoadScrollViewWithPage:currentPage-2];
    [self loadScrollViewWithPage:currentPage-1];
    [self loadScrollViewWithPage:currentPage];
    [self loadScrollViewWithPage:currentPage+1];
    [self unLoadScrollViewWithPage:currentPage+2];    

}

-(void) unloadAllViews
{
    
    for (int i=0; i<12;i++) 
        [self unLoadScrollViewWithPage:i];
}

#pragma mark - load ViewControllers

- (void)loadScrollViewWithPage:(int)page
{
    
    if (page < 0 || page >= numberOfPages)
        return;
    
    // replace the placeholder if necessary
    CalendarMonthViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:[NSBundle mainBundle] withMonth:page+1];
        controller.managedObjectContext=self.managedObjectContext;
        controller.view.tag=page;
        controller.delegate=self;
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }

}


- (void)unLoadScrollViewWithPage:(int)page
{
    if (page < 0 || page >= numberOfPages)
        return;
    
    //Elimino el controlador del array de controladores
    [viewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
    
    //Elimino la vista de scrollView
    for (int i=0; i<[self.scrollView.subviews count];i++  ) 
        if ([[self.scrollView.subviews objectAtIndex:i] tag]==page) 
            [[self.scrollView.subviews objectAtIndex:i] removeFromSuperview];
}


#pragma mark - CalendarMonthVCDelegate methods

-(void) calendarCreateNewEntryForDay:(NSDate *)dayDate
{

    [self.delegate calendarDidChooseDayForConjunto:dayDate];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self changeToConjuntosVC];    
}

-(void) calendarEditEntryForDay:(NSDate *)dayDate
{
}

#pragma mark - ConjuntosViewControllerDelegate methods

-(void) cancelChoosingConjuntoForCalendar
{
    [self dismissModalViewControllerAnimated:YES];
    
}

 #pragma mark - CalendarDayDetailVCDelegate methods

-(void) didFinishEditingCalendarDay
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) didMoveCalendarItemToTrash
{
    [[self.viewControllers objectAtIndex:currentPage] drawCalendar]; 
    [self dismissModalViewControllerAnimated:YES];
    
}


@end

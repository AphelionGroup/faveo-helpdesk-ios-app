
#import "LeftMenuViewController.h"
#import "RKDropdownAlert.h"
#import "HexColors.h"
#import "AppConstanst.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RMessage.h"
#import "RMessageView.h"
#import "Reachability.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "UIImageView+Letters.h"

@import Firebase;

@interface LeftMenuViewController ()<RMessageProtocol>{
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    Utils *utils;
    UIRefreshControl *refresh;
}

@end

@implementation LeftMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

// It called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Naaa-LeftMENU");
    
    [self addUIRefresh];

    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"device_token %@",[userDefaults objectForKey:@"deviceToken"]);
    
    [self update];
    [self getDependencies];
    
    [self.tableView reloadData];
    
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    

}
// It notifies the view controller that its view is about to be added to a view hierarchy.
-(void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    //[self.tableView reloadData];
    
}

-(void)update{
    
    [[AppDelegate sharedAppdelegate] hideProgressView];
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    NSLog(@"Role : %@",[userDefaults objectForKey:@"role"]);
    
    _user_role.text=[[userDefaults objectForKey:@"role"] uppercaseString];
    
    _user_nameLabel.text=[userDefaults objectForKey:@"profile_name"];
    _url_label.text=[userDefaults objectForKey:@"baseURL"];
    
//    [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
//                          placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    
    if([[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".png"] )
    {
        [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                              placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    }else
    {
        NSString *mystr= [[userDefaults objectForKey:@"profile_name"] substringToIndex:2];
        [_user_profileImage setImageWithString:mystr color:nil ];
    }
    
    
    NSLog(@"Name :%@ ",[userDefaults objectForKey:@"profile_name"]);
    NSLog(@"url :%@ ",[userDefaults objectForKey:@"baseURL"]);
    NSLog(@"url :%@ ",[userDefaults objectForKey:@"role"]);
    
    
    _user_profileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    
    _user_profileImage.layer.cornerRadius = _user_profileImage.frame.size.height /2;
    _user_profileImage.layer.masksToBounds = YES;
    _user_profileImage.layer.borderWidth = 0;
    
    
    _view1.alpha=0.5;
    _view1.layer.cornerRadius = 20;
    _view1.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    _view2.alpha=0.5;
    _view2.layer.cornerRadius = 20;
   _view2.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    _view3.alpha=0.5;
    _view3.layer.cornerRadius = 20;
    _view3.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    _view4.alpha=0.5;
    _view4.layer.cornerRadius = 20;
    _view4.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    _view5.alpha=0.5;
    _view5.layer.cornerRadius = 20;
    _view5.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    NSInteger open =  [globalVariables.OpenCount integerValue];
    NSInteger closed = [globalVariables.ClosedCount integerValue];
    NSInteger trash = [globalVariables.DeletedCount integerValue];
    NSInteger unasigned = [globalVariables.UnassignedCount integerValue];
    NSInteger my_tickets = [globalVariables.MyticketsCount integerValue];
    
    if(open>99){
        _c1.text=@"99+";
    }else if(open<10){
        _c1.text=[NSString stringWithFormat:@"0%ld",(long)open];
    }
    else{
        _c1.text=@(open).stringValue; }
    
    if(closed>99){
        _c4.text=@"99+";
    }
    else if(closed<10){
        _c4.text=[NSString stringWithFormat:@"0%ld",(long)closed];
    }else{
        _c4.text=@(closed).stringValue; }
    
    if(trash>99){
        _c5.text=@"99+";
    }
    else if(trash<10){
        _c5.text=[NSString stringWithFormat:@"0%ld",(long)trash];
    }else
        _c5.text=@(trash).stringValue;
    
    if(unasigned>99){
        _c3.text=@"99+";
    }else if(unasigned<10){
        _c3.text=[NSString stringWithFormat:@"0%ld",(long)unasigned];
    }
    else
        _c3.text=@(unasigned).stringValue;
    
    if(my_tickets>99){
        _c2.text=@"99+";
    }
    else if(my_tickets<10){
        _c2.text=[NSString stringWithFormat:@"0%ld",(long)my_tickets];
    }
    else
        _c2.text=@(my_tickets).stringValue;
    
    [self.tableView reloadData];
    
}

// This method used to get some values like Agents list, Ticket Status, Ticket counts, Ticket Source, SLA ..etc which are used in various places in project.
-(void)getDependencies{
    
    NSLog(@"Thread-NO1-getDependencies()-start");
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Error..!", nil)
                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
                                         iconImage:nil
                                              type:RMessageTypeError
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        
        
    }else{
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/dependency?api_key=%@&ip=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"]];
        
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
                NSLog(@"Thread-NO3-getDependencies-start-error-%@-json-%@-msg-%@",error,json,msg);
                if (error || [msg containsString:@"Error"]) {
                    
                    NSLog(@"Thread-NO4-postCreateTicket-Refresh-error == %@",error.localizedDescription);
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    //               dispatch_async(dispatch_get_main_queue(), ^{
                    //                  [self getDependencies];
                    //               });
                    
                    [self getDependencies];
                    
                    NSLog(@"Thread--NO4-call-getDependecies");
                    return;
                }
                
                if (json) {
                    
                 //   NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                    
                    
                    NSDictionary *resultDic = [json objectForKey:@"result"];
                    
                    self->globalVariables.dependencyDataDict=[json objectForKey:@"result"];
                    
                    
                    NSArray *ticketCountArray=[resultDic objectForKey:@"tickets_count"];
                    
                    
                    
                    for (int i = 0; i < ticketCountArray.count; i++) {
                        NSString *name = [[ticketCountArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *count = [[ticketCountArray objectAtIndex:i]objectForKey:@"count"];
                        if ([name isEqualToString:@"Open"]) {
                            globalVariables.OpenCount=count;
                        }else if ([name isEqualToString:@"Closed"]) {
                            globalVariables.ClosedCount=count;
                        }else if ([name isEqualToString:@"Deleted"]) {
                            globalVariables.DeletedCount=count;
                        }else if ([name isEqualToString:@"unassigned"]) {
                            globalVariables.UnassignedCount=count;
                        }else if ([name isEqualToString:@"mytickets"]) {
                            globalVariables.MyticketsCount=count;
                        }
                    }
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [refresh endRefreshing];
                            [self.tableView reloadData];
                        });
                    });
                    
                    
                }
                NSLog(@"Thread-NO5-getDependencies-closed");
            }
             ];
        }@catch (NSException *exception)
        {
            // Print exception information
            NSLog( @"NSException caught in getDependencies method in Inbox ViewController" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
            NSLog( @"In finally block");
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
    [[AppDelegate sharedAppdelegate] hideProgressView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// It tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *vc ;
    
    @try{
        switch (indexPath.row)
        {
            case 1:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CreateTicket"];
                break;
                
            case 2:
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                break;
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"InboxID"];
                break;
            case 4:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyTicketsID"];
                break;
            case 5:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"UnassignedTicketsID"];
                break;
            case 6:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ClosedTicketsID"];
                break;
                
            case 7:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"TrashTicketsID"];
                break;
                
            case 8:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ClientListID"];
                break;
                
            case 10:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"AboutVCID"];
                break;
                
                
            case 11:
                
                [self wipeDataInLogout];

                
                if (self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:NSLocalizedString(@" Faveo Helpdesk ", nil)
                                                  subtitle:NSLocalizedString(@"You've logged out, successfully...!", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeSuccess
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionNavBarOverlay
                                      canBeDismissedByUser:YES];
                
            
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Login"];
                
                break;
                       //
            default:
                break;
        }
    }@catch (NSException *exception)
    {
        // Print exception information
        NSLog( @"NSException caught in LeftMenu View Controller" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    @finally
    {
        // Cleanup, in both success and fail cases
        NSLog( @"In finally block");
        
    }
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}

// It asks the delegate for the height to use for a row in a specified location.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 9) {
        return 0;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
}

// Logout method is called
-(void)wipeDataInLogout{
    
   // [self sendDeviceToken];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
}

//-(void)sendDeviceToken{
//
//    // NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//    NSString *url=[NSString stringWithFormat:@"%@fcmtoken?user_id=%@&fcm_token=%s&os=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"user_id"],"0",@"ios"];
//    @try{
//        MyWebservices *webservices=[MyWebservices sharedInstance];
//        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
//            if (error || [msg containsString:@"Error"]) {
//                if (msg) {
//
//                    // [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
//                    NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
//                }else if(error)  {
//                    //                [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
//                    NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
//                }
//                return ;
//            }
//            if (json) {
//
//                NSLog(@"Thread-sendAPNS-token-json-%@",json);
//            }
//
//        }];
//    }@catch (NSException *exception)
//    {
//        // Print exception information
//        NSLog( @"NSException caught In sendDeviceToken method in LeftMenu ViewController" );
//        NSLog( @"Name: %@", exception.name);
//        NSLog( @"Reason: %@", exception.reason );
//        return;
//    }
//    @finally
//    {
//        // Cleanup, in both success and fail cases
//        NSLog( @"In finally block");
//
//    }
//}

// It tells the delegate the table view is about to draw a cell for a particular row.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
}

// It tells the delegate that a specified row is about to be selected.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    // if ( indexPath.section == 0 ) return nil;
    
    
    
    // first 3 rows in any section should not be selectable
    if ( (indexPath.row ==0) || (indexPath.row==2) ) return nil;
    
    // By default, allow row to be selected
    return indexPath;
}


-(void)addUIRefresh{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *refreshing = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle,NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    refresh=[[UIRefreshControl alloc] init];
    refresh.tintColor=[UIColor whiteColor];
    refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refresh atIndex:0];
    
}

-(void)reloadd{
    //[self getDependencies];
    [self update];
    [self.tableView reloadData];
    
    [refresh endRefreshing];
}


@end


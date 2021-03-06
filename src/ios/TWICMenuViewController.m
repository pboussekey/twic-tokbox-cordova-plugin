//
//  TWICMenuViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICMenuViewController.h"
#import "FZAccordionTableView.h"
#import "TWICConstants.h"
#import "TWICMenuActionTableViewCell.h"
#import "TWICMenuAccordionHeaderView.h"
#import "TWICUserManager.h"

@interface TWICMenuViewController ()<UITableViewDelegate,UITableViewDataSource,FZAccordionTableViewDelegate>
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *separatorview;

//data
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *users;
@end

@implementation TWICMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //accordion view
    [self.tableView registerNib:[UINib nibWithNibName:@"TWICMenuAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:[TWICMenuAccordionHeaderView description]];
    
    [self configureSkin];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData:) name:TWIC_NOTIFICATION_USER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData:) name:TWIC_NOTIFICATION_USER_DISCONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData:) name:TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData:) name:TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(refreshData:) name:TWIC_NOTIFICATION_SUBSCRIBER_VIDEO_CHANGED object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData:nil];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)refreshData:(NSNotification *)notification{
    //remove the current user from the list
    self.users = [NSMutableArray arrayWithCapacity:[TWICUserManager sharedInstance].allUsers.count -1];
    for(NSDictionary *user in [TWICUserManager sharedInstance].allUsers){
        if([[TWICUserManager sharedInstance]isCurrentUser:user] == NO){
            [self.users addObject:user];
        }
    }
    [self refreshUI];
}

-(void)refreshUI{
    self.titleLabel.text = [NSString stringWithFormat:@"%d Members",(int)self.users.count];
    [self.tableView reloadData];
}

-(void)configureSkin{
    self.view.backgroundColor = TWIC_COLOR_BLACK;
    self.tableView.backgroundColor = TWIC_COLOR_BLACK;
    self.headerView.backgroundColor = TWIC_COLOR_BLACK;
    self.closeButton.backgroundColor = CLEAR_COLOR;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.closeButton.backgroundColor = CLEAR_COLOR;
    self.separatorview.backgroundColor = TWIC_COLOR_GREY;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma TableView Management
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *user = self.users[section];
    return [[[TWICUserManager sharedInstance]actionsForUser:user] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kDefaultMenuActionTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDefaultAccordionHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *user = self.users[indexPath.section];
    NSDictionary *action = [[[TWICUserManager sharedInstance]actionsForUser:user] objectAtIndex:indexPath.row];
    TWICMenuActionTableViewCell *cell = nil;
    if(action[UserActionIsRedKey]){
        cell = (TWICMenuActionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Admin%@",[TWICMenuActionTableViewCell description]] forIndexPath:indexPath];
    }else{
        cell = (TWICMenuActionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[TWICMenuActionTableViewCell description] forIndexPath:indexPath];
    }
    
    [cell configureWithAction:action user:user];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TWICMenuAccordionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[TWICMenuAccordionHeaderView description]];
    NSDictionary *user = self.users[section];
    [headerView configureWithUser:user];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.delegate){
        NSDictionary *user = self.users[indexPath.section];
        NSDictionary *action = [[[TWICUserManager sharedInstance]actionsForUser:user] objectAtIndex:indexPath.row];
        [self.delegate TWICMenuViewController:self didSelectAction:action forUser:user];
    }
}
#pragma mark - <FZAccordionTableViewDelegate> -
- (BOOL)tableView:(FZAccordionTableView *)tableView canInteractWithHeaderAtSection:(NSInteger)section {
    //has actions ?
    if([[[TWICUserManager sharedInstance]actionsForUser:self.users[section]] count] > 0){
        return YES;
    }
    return NO;
}

- (void)tableView:(nonnull FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header{
    [(TWICMenuAccordionHeaderView *)header willOpen];
}

- (void)tableView:(nonnull FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header{
    [(TWICMenuAccordionHeaderView *)header willClose];
}

@end

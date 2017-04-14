//
//  StreamGridViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamGridViewController.h"
#import "TWICStreamCollectionViewCell.h"
#import "TWICTokClient.h"

@interface TWICStreamGridViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation TWICStreamGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

#pragma mark - Keyboard Management
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Collection view management

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [TWICTokClient sharedInstance].orderedSubscriberIDs.count + 1 ; //the publisher
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TWICStreamCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TWICStreamCollectionViewCell description]
                                                                                        forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        [(TWICStreamCollectionViewCell*)cell configureWithPublisher:[TWICTokClient sharedInstance].publisher];
    }
    else
    {
        NSString *subscriberID = [TWICTokClient sharedInstance].orderedSubscriberIDs[indexPath.row-1];
        [(TWICStreamCollectionViewCell*)cell configureWithSubscriber:[[TWICTokClient sharedInstance]subscriberForStreamID:subscriberID]];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self.delegate TWICStreamGridViewControllerDidSelectPublisher:self];
    }
    else
    {
        [self.delegate TWICStreamGridViewController:self didSelectSubscriberID:[TWICTokClient sharedInstance].orderedSubscriberIDs[indexPath.row-1]];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if([TWICTokClient sharedInstance].orderedSubscriberIDs.count+1==1){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(50, 10, 50, 10);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //change display following numbers
    NSUInteger viewsCount = [TWICTokClient sharedInstance].orderedSubscriberIDs.count + 1;
    if(viewsCount == 1)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width, MAIN_SCREEN.bounds.size.height);
    }
    else if(viewsCount == 2)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(viewsCount == 3)
    {
        if(indexPath.row == 2)
        {
            return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
        }
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(viewsCount == 4)
    {
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/4);
}

-(void)refresh{
    [self.collectionView reloadData];
}
@end

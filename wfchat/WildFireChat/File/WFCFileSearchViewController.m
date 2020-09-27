//
//  WFCFileSearchViewController.m
//  WildFireChat
//
//  Created by 赵伟 on 2020/9/27.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFileSearchViewController.h"

@interface WFCFileSearchViewController ()

@property (nonatomic, strong) NSMutableArray *searchList;

@property(nonatomic, assign)BOOL sorting;
@property(nonatomic, assign)BOOL needSort;

@end

@implementation WFCFileSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
}

#pragma mark - UISearchControllerDelegate


- (void)didPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.needSort = YES;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        NSString *searchString = [searchController.searchBar text];
        if (self.searchList!= nil) {
            [self.searchList removeAllObjects];

        }
        self.needSort = YES;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    for (id cencelButton in [searchBar.subviews[0] subviews])
    {
        if([cencelButton isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cencelButton;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - get/set
-(NSMutableArray *)searchList{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

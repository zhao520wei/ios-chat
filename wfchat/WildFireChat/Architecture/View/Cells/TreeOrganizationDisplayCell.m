//
//  TreeOrganizationDisplayCell.m
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TreeOrganizationDisplayCell.h"
#import "SinglePersonNodeView.h"
#import "OrganizationNodeView.h"
#import "WFCUProfileTableViewController.h"
#import "UIView+TYAlertView.h"

@interface TreeOrganizationDisplayCell ()<NodeTreeViewDelegate>

@property (nonatomic, strong) NodeTreeView *treeView;

@property (nonatomic, assign) NodeTreeViewStyle treeStyle;

@property (nonatomic, assign) NodeTreeRefreshPolicy treeRefreshPolicy;

@end

@implementation TreeOrganizationDisplayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier treeStyle:(NodeTreeViewStyle)treeStyle treeRefreshPolicy:(NodeTreeRefreshPolicy)policy{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.treeStyle = treeStyle;
        self.treeRefreshPolicy = policy;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier treeStyle:(NodeTreeViewStyle)treeStyle{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.treeStyle = treeStyle;
        [self setupSubviews];
    }
    return self;
}

#pragma mark ======== Custom Delegate ========

#pragma mark NodeTreeViewDelegate
- (id<NodeViewProtocol>_Nonnull)nodeTreeView:(NodeTreeView *)treeView viewForNode:(id<NodeModelProtocol>)node{
    id _node = node;
    if ([_node isMemberOfClass:[SinglePersonNode class]]) {
        SinglePersonNodeView * singleNode = [[SinglePersonNodeView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, node.nodeHeight) withIsAbleSelected:self.isAbleSelected];
        return singleNode;
    }else if([_node isMemberOfClass:[OrganizationNode class]]){
        return [[OrganizationNodeView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, node.nodeHeight)];
    }
    SinglePersonNodeView * singleNode =  [[SinglePersonNodeView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, node.nodeHeight) withIsAbleSelected:self.isAbleSelected];
    return singleNode;
}

- (CGFloat)nodeTreeView:(NodeTreeView *_Nonnull)treeView indentAtNodeLevel:(NSInteger)nodeLevel{
    if (NodeTreeViewStyleBreadcrumbs == self.treeStyle) {
        return 0;
    }else if (NodeTreeViewStyleExpansion == self.treeStyle){
        if (nodeLevel == 1) {
            return 0;
        }else{
            return 30*nodeLevel;
        }
    }else{
        return 0;
    }
}

- (void)nodeTreeView:(NodeTreeView *_Nonnull)treeView didSelectNode:(id<NodeModelProtocol>_Nonnull)node{
    id selectNode = node;

    if ([selectNode isMemberOfClass:[SinglePersonNode class]]) {
        SinglePersonNode *personNode = (SinglePersonNode *)selectNode;
        if (personNode.subNodes.count == 0 && !self.isAbleSelected) {
            WFCUProfileTableViewController * profileVC = [[WFCUProfileTableViewController alloc]init];
            profileVC.userId = personNode.uid;
            profileVC.hidesBottomBarWhenPushed = YES;
            [self.viewController.navigationController pushViewController:profileVC animated:YES];
            return;
        }
        
    }
    
    //通过node来刷新headerView，通过回调传给外界
    if (self.selectNode) {
        if ([selectNode isMemberOfClass:[SinglePersonNode class]]  && self.isAbleSelected) {
            SinglePersonNode *personNode = (SinglePersonNode *)selectNode;
            personNode.selected = !personNode.selected;
            self.selectNode(personNode);
        } else {
            if ([selectNode isMemberOfClass:[OrganizationNode class]]) {
                OrganizationNode *node = (OrganizationNode *)selectNode;
                if (node.subNodes.count > 0) {
                    self.selectNode(selectNode);
                }
            }else {
                 self.selectNode(selectNode);
            }
            
        }
    }
}

#pragma mark ======== Private Methods ========

- (void)setupSubviews{
    [self.contentView addSubview:self.treeView];
    NSLog(@"TreeOrganizationDisplayCell height : %f     treeView height: %f", self.contentView.frame.size.height ,self.treeView.frame.size.height );
}

/**
 刷新node节点对应的树
 */
- (void)reloadTreeViewWithNode:(BaseTreeNode *)node RowAnimation:(UITableViewRowAnimation)animation{
    _node = node;
    [_treeView reloadTreeViewWithNode:node RowAnimation:animation];
}

#pragma mark ======== Setters && Getters ========
- (void)setNode:(BaseTreeNode *)node{
    _node = node;
    [_treeView reloadTreeViewWithNode:_node];
}

- (NodeTreeView *)treeView{
    if (!_treeView) {
        _treeView = [[NodeTreeView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height) treeViewStyle:self.treeStyle];
        _treeView.treeDelegate = self;
        _treeView.refreshPolicy = self.treeRefreshPolicy;
    }
    return _treeView;
}
@end

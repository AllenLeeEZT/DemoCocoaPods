//
//  TableViewController.m
//  DemoCocoaPods
//
//  Created by allenlee on 2014/10/2.
//  Copyright (c) 2014年 EZTABLE. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray *dataArry;
- (IBAction)reload:(id)sender;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
 * - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 *  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 *
 *  // Configure the cell...
 *
 *  return cell;
 * }
 */

- (IBAction)reload:(id)sender {
    NSLog(@"LOG:  reload");
}

@end

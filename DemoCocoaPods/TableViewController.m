//
//  TableViewController.m
//  DemoCocoaPods
//
//  Created by allenlee on 2014/10/2.
//  Copyright (c) 2014年 EZTABLE. All rights reserved.
//

#import "TableViewController.h"
#import <PromiseKit.h>
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <OGImageExtensions.h>

@interface TableViewController ()

@property (nonatomic, strong) NSArray *dataArray;
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    id obj = self.dataArray[indexPath.row];

    //name
    cell.textLabel.text = obj[@"name"];
    //image
    NSString *urlString = [NSString stringWithFormat:@"http://www.eztable.com.tw%@", obj[@"thumb1_mini"]];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"restaurant"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        image = [image circularImage];
        cell.imageView.image = image;
    }];

    return cell;
}

- (IBAction)reload:(id)sender {
    NSLog(@"LOG:  reload");
    //http://api.eztable.com/v2/search/search_restaurant_by_latlng/{LATITUDE}/{LONGITUDE}/?{OPTIONAL PARAMETERS}

    BOOL isProduction = NO;
    NSString *lat = @"25.0367805";
    NSString *lon = @"121.5426982";
    int n = 7;

    NSString *urlString =
    [NSString stringWithFormat:@"http://api%@.eztable.com/v2/search/search_restaurant_by_latlng/%@/%@/?n=%i"
    , (isProduction) ? @""    :@"-dev"
    , lat, lon
    , n
    ];

    [SVProgressHUD showWithStatus:@"loading..."];

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [NSURLConnection GET:urlString].then (^(NSDictionary *jsonDic) {
            //        NSLog(@"LOG:  jsonDic: %@", jsonDic);
            self.dataArray = jsonDic[@"data"][@"docs"];
            [self.tableView reloadData];

            [TSMessage showNotificationInViewController:self
                                                  title:@"Good Job"
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:0.5
            ];
        }).catch (^(NSError *error) {
            NSLog(@"LOG:  error: %@", error);
            NSString *errorString = error.userInfo[NSLocalizedDescriptionKey];
            [TSMessage showNotificationWithTitle:errorString type:(TSMessageNotificationTypeError)];
        }).finally (^{
            [SVProgressHUD dismiss];
        });
    }];
}

@end

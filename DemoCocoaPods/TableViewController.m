//
//  TableViewController.m
//  DemoCocoaPods
//
//  Created by allenlee on 2014/10/2.
//  Copyright (c) 2014年 EZTABLE. All rights reserved.
//

#import "TableViewController.h"
#import <PromiseKit.h>
#import <PromiseKit+UIKit.h>
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

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address:" message:@"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reload", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = @"台北市敦化南路二段216號";
        [alert promise].then (^{
            //Geocode
            UITextField *textField = [alert textFieldAtIndex:0];
            NSString *address = textField.text;
            NSString *geoCoderUrlString = @"http://maps.googleapis.com/maps/api/geocode/json";
            NSDictionary *query = @{ @"address" : address };
            geoCoderUrlString = [geoCoderUrlString urlEncodeUsingEncoding:NSUTF8StringEncoding];

            [SVProgressHUD showWithStatus:@"loading..."];

            [NSURLConnection GET:geoCoderUrlString query:query].then (^(NSDictionary *jsonDic) {
                //Prepare request URL
                NSArray *results = jsonDic[@"results"];

                return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
                    if (results.count == 0) {
                        NSString *status = jsonDic[@"status"];
                        return rejecter([NSError errorWithDomain:PMKErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey : status }]);
                    }

                    NSDictionary *loaction = results[0][@"geometry"][@"location"];
                    NSString *lat = [NSString stringWithFormat:@"%@", loaction[@"lat"]];
                    NSString *lon = [NSString stringWithFormat:@"%@", loaction[@"lng"]];
                    NSString *urlString = [self urlFromLat:lat lon:lon];

                    fulfiller(urlString);
                }];
            }).then (^(NSString *urlString) {
                //Get restaurants
                return [NSURLConnection GET:urlString].then (^(NSDictionary *jsonDic) {
                    //        NSLog(@"LOG:  jsonDic: %@", jsonDic);
                    self.dataArray = jsonDic[@"data"][@"docs"];
                    [self.tableView reloadData];
                    if (self.dataArray.count) {
                        //scroll to first row
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
                    }

                    [TSMessage showNotificationInViewController:self
                                                          title:@"Good Job"
                                                       subtitle:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:0.5
                    ];
                });
            }).catch (^(NSError *error) {
                //Catch error
                NSLog(@"LOG:  error: %@", error);
                NSString *errorString = error.userInfo[NSLocalizedDescriptionKey];
                [TSMessage showNotificationWithTitle:errorString type:(TSMessageNotificationTypeError)];
            }).finally (^{
                [SVProgressHUD dismiss];
            });
        }); // [END]  [alert promise].then
    }]; // [END]  clearDiskOnCompletion
}

- (NSString *)urlFromLat:(NSString *)lat lon:(NSString *)lon {
    if (!lat.length) {
        lat = @"25.0367805";
    }
    if (!lon.length) {
        lon = @"121.5426982";
    }
    BOOL isProduction = NO;
    int n = 7;

    NSString *urlString =
    [NSString stringWithFormat:@"http://api%@.eztable.com/v2/search/search_restaurant_by_latlng/%@/%@/?n=%i"
    , (isProduction) ? @""    :@"-dev"
    , lat, lon
    , n
    ];

    return urlString;
}

@end

#pragma mark - NSString (URLEncoding)
@implementation NSString (URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
           (CFStringRef)self,
           NULL,
           (CFStringRef)@"!*'\"();@+$,#[]% ",                                                                      //@"!*'\"();:@&=+$,/?%#[]% "
           CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end

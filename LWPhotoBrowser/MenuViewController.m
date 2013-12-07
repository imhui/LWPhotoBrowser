//
//  MenuViewController.m
//  LWPhotoGallery
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "MenuViewController.h"
#import "LWPhotoBrowser.h"
#import "LWPhoto.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = @"Remote Image";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:0];
    LWPhoto *photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/h%3D1200%3Bcrop%3D0%2C0%2C1920%2C1200/sign=19af96f879899e51678e3e167297e250/5d6034a85edf8db1e74639610b23dd54564e744e.jpg"]];
    photo.caption = @"111";
    [photos addObject:photo];
    
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=fa485779fa1986184147e8847ed52f73/a1ec08fa513d269710bdda4557fbb2fb4316d8b8.jpg"]];
    photo.caption = @"222";
    [photos addObject:photo];
    
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/w%3D2048/sign=a70abe908601a18bf0eb154faa170508/42166d224f4a20a46afd047b91529822730ed0ae.jpg"]];
    [photos addObject:photo];
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D1366%3Bcrop%3D0%2C0%2C1366%2C768/sign=563bbdc5f9dcd100cd9cfc2244bd7c73/cf1b9d16fdfaaf519e2296778d5494eef11f7a30.jpg"]];
    [photos addObject:photo];
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D2048/sign=a098c1350b24ab18e016e63701c2e7cd/8b82b9014a90f6038173b8543b12b31bb151ede6.jpg"]];
    [photos addObject:photo];
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=6551f0934034970a4773172fa1f2d0c8/50da81cb39dbb6fd9fe4dd9a0824ab18962b37ca.jpg"]];
    [photos addObject:photo];
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/w%3D2048/sign=29a07b944610b912bfc1f1fef7c5fd03/d043ad4bd11373f066b353b0a50f4bfbfbed0414.jpg"]];
    [photos addObject:photo];
    photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D1366%3Bcrop%3D0%2C0%2C1366%2C768/sign=edb1329c8026cffc692abbb18f3771f3/c2cec3fdfc0392458c7ca50a8594a4c27c1e25ed.jpg"]];
    [photos addObject:photo];
    
    
    LWPhotoBrowser *browser = [[LWPhotoBrowser alloc] init];
    browser.photos = photos;
    [self.navigationController pushViewController:browser animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

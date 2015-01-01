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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Remote Image";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Local Image";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:0];
    LWPhoto *photo = nil;
    
    if (indexPath.row == 0) {
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://g.hiphotos.baidu.com/image/w%3D2048/sign=9f057fd7d52a60595210e61a1c0c349b/caef76094b36acafe0d705e27ed98d1001e99cfd.jpg"]];
        photo.caption = @"埃菲尔铁塔";
        [photos addObject:photo];
        
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=9463f8ec39c79f3d8fe1e3308e99cc11/7a899e510fb30f241ff95110ca95d143ad4b0345.jpg"]];
        photo.caption = @"菲尼斯泰尔布列塔尼半岛";
        [photos addObject:photo];
        
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=974b1a66d488d43ff0a996f24926d31b/4afbfbedab64034f13b87f15adc379310a551daf.jpg"]];
        photo.caption = @"南科西嘉省阿雅克肖海滩";
        [photos addObject:photo];
        
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://h.hiphotos.baidu.com/image/w%3D2048/sign=17d2c536347adab43dd01c43bfecb21c/503d269759ee3d6dba30f1d541166d224f4ade3e.jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=a66c6107ba99a9013b355c3629ad0b7b/0df3d7ca7bcb0a464b43362a6963f6246b60af44.jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/w%3D2048/sign=920393380b24ab18e016e63701c2e7cd/8b82b9014a90f603b3e8ea593b12b31bb051ed50.jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=b4f1367c9a22720e7bcee5fa4ff30a46/5243fbf2b21193130d786cae67380cd791238df1.jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/w%3D2048/sign=721ab42d938fa0ec7fc7630d12af58ee/d52a2834349b033b4b7f8ac417ce36d3d539bd3c.jpg"]];
        [photos addObject:photo];
    }
    else if (indexPath.row == 1) {
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"3" ofType:@"jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"4" ofType:@"jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"5" ofType:@"jpg"]];
        [photos addObject:photo];
        photo = [LWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"6" ofType:@"jpg"]];
        [photos addObject:photo];
    }
    
    
    
    LWPhotoBrowser *browser = [[LWPhotoBrowser alloc] initWithPhotos:photos photoIndex:3];
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

//
//  ADPAssetShareTableViewController.m
//  AirdropPlus
//
//  Created by Stone, Jordan Matthew (US - Denver) on 5/2/14.
//  Copyright (c) 2014 Jordan Stone. All rights reserved.
//

#import "ADPAssetShareTableViewController.h"
@import MultipeerConnectivity;
#import "JSLoadingView.h"



@interface ADPAssetShareTableViewController () <UIAlertViewDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *connectedPeer;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;
@property (nonatomic, strong) JSLoadingView *loadingView;

@end

@implementation ADPAssetShareTableViewController

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
    self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView setAllowsMultipleSelection:YES];
    
#ifdef BROWSER
    self.assets = [NSMutableArray arrayWithObject:[[NSBundle mainBundle] URLForResource:@"rhodes.png" withExtension:nil]];
#else
    self.assets = [NSMutableArray array];
#endif
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secretAdvertiser:)];
    [tapGesture setNumberOfTapsRequired:3];
    
    [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)secretAdvertiser:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"Did secret triple tap. You so sneaky.");
    
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"Advertiser"];
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:@"jms-airdrop"];
    [self.serviceAdvertiser setDelegate:self];
    [self.serviceAdvertiser startAdvertisingPeer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.assets count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssetCell" forIndexPath:indexPath];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [self.assets[indexPath.row] lastPathComponent]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[self.session connectedPeers] count] == 1) {
        // We have someone to send stuff to
        [self.session sendResourceAtURL:self.assets[indexPath.row] withName:[self.assets[indexPath.row] lastPathComponent] toPeer:self.connectedPeer withCompletionHandler:^(NSError *error) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }];
    }
}

#pragma mark - UIBarButtonItemMethods
- (IBAction)shareAssetsItemTapped:(id)sender {
    self.loadingView = [[JSLoadingView alloc] initWithLoadingText:@"Searching for peers..."];
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
    
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"Browser"];
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:@"jms-airdrop"];
    self.session = [[MCSession alloc] initWithPeer:peerID];
    [self.session setDelegate:self];
    
    [self.serviceBrowser setDelegate:self];
    
    [self.serviceBrowser startBrowsingForPeers];
}


- (IBAction)addAssetItemTapped:(id)sender {
    UIAlertView *addAssetAlert = [[UIAlertView alloc] initWithTitle:nil message:@"URL of remote asset:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Fetch", nil];
    
    [addAssetAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [addAssetAlert show];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Get the text from the alert view
    NSString *assetURL = [alertView textFieldAtIndex:0].text;
    if (assetURL.length != 0) {
        // Add the asset name to our list
        [self.assets addObject:[NSURL URLWithString:assetURL]];
        [self.tableView reloadData];
    }
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    [self.loadingView setLoadingText:@"Found Peer!"];
    [self.loadingView stopAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loadingView removeFromSuperview];
    });
    
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    [browser stopBrowsingForPeers];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Did not start browsing: %@", [error localizedDescription]);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    self.session = [[MCSession alloc] initWithPeer:advertiser.myPeerID];
    [self.session setDelegate:self];
    
    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"Did not start advertising: %@", [error localizedDescription]);
}

#pragma mark - MCSessionDelegate Methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"Peers connected");
            self.connectedPeer = peerID;
            break;
        case MCSessionStateNotConnected:
        case MCSessionStateConnecting:
            self.connectedPeer = nil;
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"Receiving %@", resourceName);
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:CGRectMake(0, 0, 320, 568)];
    
    [self.view addSubview:imageView];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

@end

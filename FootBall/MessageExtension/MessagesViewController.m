//
//  MessagesViewController.m
//  MessageExtension
//
//  Created by 张立丹 on 2020/3/4.
//  Copyright © 2020 李欢. All rights reserved.
//

#import "MessagesViewController.h"


#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface MessagesViewController ()


@property (nonatomic,strong) NSMutableArray *arrImg;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.arrImg = [NSMutableArray array];
    for (int i = 0; i < 60; i++) {
        NSString *img = [NSString stringWithFormat:@"ball%d",i+1];
        NSString *b = [[NSBundle mainBundle]pathForResource:img ofType:@"png"];
        NSURL *url = [[NSURL alloc]initFileURLWithPath:b];
        MSSticker *ticker = [[MSSticker alloc]initWithContentsOfFileURL:url localizedDescription:@"" error:nil];
        [self.arrImg addObject:ticker];
    }
     [self createStickerBrowser];
}

- (void)createStickerBrowser
{
    MSStickerBrowserViewController *browser = [[MSStickerBrowserViewController alloc]initWithStickerSize:MSStickerSizeRegular];
    [self addChildViewController:browser];
    [self.view addSubview:browser.view];
    
    browser.stickerBrowserView.backgroundColor=[UIColor whiteColor];
    browser.stickerBrowserView.dataSource  = self;
    browser.view.frame = self.view.frame;
}

- (NSInteger)numberOfStickersInStickerBrowserView:(MSStickerBrowserView *)stickerBrowserView
{
    return self.arrImg.count;
}
- (MSSticker *)stickerBrowserView:(MSStickerBrowserView *)stickerBrowserView stickerAtIndex:(NSInteger)index
{
    return self.arrImg[index];
}

#pragma mark - Conversation Handling
-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
}


@end

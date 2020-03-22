//
//  ViewController.m
//  FootBall
//
//  Created by 张立丹 on 2020/3/3.
//  Copyright © 2020 李欢. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "ImageCollectionCell.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height
#define rmStatusBarH                                     ([UIApplication sharedApplication].statusBarFrame.size.height)
#define kStatusBarH                                      ([UIApplication sharedApplication].statusBarFrame.size.height)//(44/20)
#define kDevice_Is_iPhoneX                               ((rmStatusBarH == 44.0) ? YES : NO)

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic ,strong) UICollectionView *collection;

@property (nonatomic ,strong) NSMutableArray *arrImg;

@property (nonatomic, strong)WKWebView *webView;

@property (nonatomic,assign) BOOL isShowWeb;//是否展示web

@property (nonatomic ,strong) NSString *urlString;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor  =[UIColor whiteColor];
    _isShowWeb = NO;
    [self getRequest];
}

- (void)showTopView
{
    if (_isShowWeb) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.hidden = YES;
        [self setupIndicatorView];
        [self setupWebView];
    }else{
        self.title = @"SFT60-STICKERS-LIFE";
        self.arrImg = [NSMutableArray array];
        for (int i = 0; i < 60; i++) {
            NSString *img = [NSString stringWithFormat:@"ball%d",i+1];
            [self.arrImg addObject:img];
        }
         CGFloat topOriginY = 0;
        if (kDevice_Is_iPhoneX) {
            topOriginY = 0;
        }else{
            topOriginY = 64;
        }

        self.navigationController.navigationBar.translucent = false;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = layout.minimumInteritemSpacing = 0;//CGRectMake(0, topOriginY, Width, Height-64)
        self.collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        self.collection.dataSource =self;
        self.collection.delegate = self;
        self.collection.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.collection];
        self.edgesForExtendedLayout = UIRectEdgeTop;
        [self.collection registerNib:[UINib nibWithNibName:@"ImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionCell"];
    }
}


- (void)setupIndicatorView
{
   self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [self.view addSubview:self.activityIndicator];
    //设置小菊花的frame
    self.activityIndicator.frame= CGRectMake(Width/2.0-50, Height/2.0-50, 100, 100);
    //设置小菊花颜色
    self.activityIndicator.color = [UIColor grayColor];
    //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
    self.activityIndicator.hidesWhenStopped = NO;
    [self.activityIndicator startAnimating];
}

- (void)setupWebView
{
    NSString *urlString = _urlString;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    CGFloat height;
    CGFloat topOriginY = 0;
    if (kDevice_Is_iPhoneX) {
        height = 84;
        topOriginY = -10;
    }else{
        height = 49;
    }
    
    config.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = false;
    } else {
        config.requiresUserActionForMediaPlayback = YES;
    }
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
     self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, Width, Height -height) configuration:config];
     self.webView.backgroundColor = [UIColor clearColor];
     self.webView.UIDelegate = self;
     self.webView.navigationDelegate = self;
    self.webView.hidden = YES;
     NSURLRequest *cacheRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
     [self.webView loadRequest:cacheRequest];
     [self.view addSubview:self.webView];
    
    UIView *bottomView  = [[UIView alloc]initWithFrame:CGRectMake(0, self.webView.frame.origin.y+self.webView.frame.size.height , Width, height)];
    [self.view addSubview:bottomView];
    
    NSArray *titleArrs = @[@"首页",@"后退",@"前进",@"刷新",@"退出"];
    NSArray *imageArrs = @[@"home",@"houtui",@"qianjin",@"shuaxin",@"tuichu"];
    
    CGFloat btnWidth = Width/5.0;
    for (int i=0; i<titleArrs.count; i++) {
        NSString *title = titleArrs[i];
        NSString *imageName = imageArrs[i];
        UIButton *actionBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth*i, topOriginY, btnWidth, height)];
       [actionBtn setTitle:title forState:UIControlStateNormal];
       [actionBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
       [actionBtn setTitleColor:[UIColor colorWithRed:63/255.0 green:63/255.0 blue:63/255.0 alpha:1] forState:UIControlStateNormal];
       actionBtn.titleLabel.font  = [UIFont systemFontOfSize:13];
       [self setButtonLayout:actionBtn];
        actionBtn.tag = i;
        [actionBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
       [bottomView addSubview:actionBtn];

    }
}
- (void)renewWebView
{
    NSURLRequest *cacheRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.webView loadRequest:cacheRequest];
}
// 内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
     [self.activityIndicator stopAnimating];
    self.webView.hidden = NO;
}
- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 0) {
        //首页 操作就是重新加载当前webview
        [self renewWebView];
    }else if (btn.tag == 1){
        //后退
        if (self.webView.canGoBack) {
            [self.webView goBack];
        }
    }else if (btn.tag == 2){
        //前进
        if (self.webView.canGoForward) {
            [self.webView goForward];
        }
    }else if (btn.tag == 3){
        //刷新
        [self.webView reload];
    }else if (btn.tag == 4){
        //退出
        [self showOkayCancelAlert];
    }
}


- (void)showOkayCancelAlert {
        NSString *title = @"退出";
        NSString *message = @"是否确定要退出";
        NSString *cancelButtonTitle = @"取消";
        NSString *otherButtonTitle = @"确定";

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];

        __weak typeof(self) ws = self;
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [ws quitcation];
        }];

        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
}

- (void)quitcation {
    exit(0);
}

- (void)setButtonLayout:(UIButton *)btn
{
    btn.titleEdgeInsets = UIEdgeInsetsMake(btn.imageView.frame.size.height+5, -btn.imageView.frame.size.width, 0, 0);
     btn.imageEdgeInsets = UIEdgeInsetsMake(-btn.titleLabel.bounds.size.height, 0, 0, -btn.titleLabel.bounds.size.width);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrImg.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
      ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionCell" forIndexPath:indexPath];
    cell.contentImageView.image =  [UIImage imageNamed:self.arrImg[indexPath.row]];
    return cell;
}

-(void)collectionView:( UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath
{
    
    NSString *name = [self.arrImg objectAtIndex:indexPath.item];
    UIImage *image = [UIImage imageNamed:name];
    NSString *titel = @"shareIcons";
//   NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[image,titel] applicationActivities:nil];
    controller.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
       
    };
    NSArray *regectArr = @[UIActivityTypePostToWeibo,UIActivityTypePostToFacebook];
    controller.excludedActivityTypes = regectArr;
    [self presentViewController:controller animated:YES completion:nil];
}

-(BOOL)collectionView:( UICollectionView *)collectionView shouldSelectItemAtIndexPath:( NSIndexPath *)indexPath
{
    return YES ;
}

- (CGSize)collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath
{
    return CGSizeMake ((Width-60)/3.0 , (Width-60)/3.0 );
}

-(UIEdgeInsets)collectionView:( UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section
{
    return UIEdgeInsetsMake (15 , 10 , 15 , 10 );
}
//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
 
    return 10;
 
}
 
//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}


-(void)getRequest
{
     NSURL *url = [NSURL URLWithString:@"http://toxli.cn/wb/api/getAppInfo"];
    //2.创建请求对象
     //请求对象内部默认已经包含了请求头和请求方法（GET）
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     //3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) ws  = self;
     NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error == nil) {
             //6.解析服务器返回的数据
             //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (dict) {
                NSString *showWeb = [dict objectForKey:@"showWeb"];
                self->_isShowWeb = [showWeb intValue];
                self->_urlString = [dict objectForKey:@"url"];
                dispatch_async(dispatch_get_main_queue(), ^{
                   // UI更新代码
                   [ws showTopView];
                });
                
            }
            NSLog(@"%@",dict);
         }
    }];
     //5.执行任务
    [dataTask resume];
 }

@end


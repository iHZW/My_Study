//
//  TwoPageViewController.m
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//

#import "TwoPageViewController.h"
#import "Monkey.h"
#import "Cat.h"

/**< BSDSocket 第一步 导入头文件 */
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

/**< BSDSocket (C语言实现),  CFSorket */

static const char *server_ip = "127.0.0.1";
static const short server_port = 6969;

struct MonkeyInfo {
    NSInteger index;
    const char * _Nonnull name;
    const char * _Nonnull type;
};

@interface TwoPageViewController ()

@property (nonatomic, strong) UIButton *tempBtn;

@property (nonatomic, assign) int client_socket;

@end

@implementation TwoPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"第二界面";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    Monkey *monkey = [[Monkey alloc] init];
//    [monkey sendMessage:@"我是猴孙"];
//
//    Cat *tempCat = [Cat new];
//    [tempCat sendMessageName:@"我是咪咪" age:05];
//    [Monkey sendClassMessage:@"我是爷爷"];
    
//    [[Monkey class] performSelector:@selector(sendClassMessage:) withObject:@"perform爷爷"];
    
    NSMethodSignature *methodSignature = [[Monkey class] methodSignatureForSelector:@selector(sendClassMessage:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:[Monkey class]];
    [invocation setSelector:@selector(sendClassMessage:)];
    NSString *str = @"invocation爷爷";
    [invocation setArgument:&str atIndex:2];
    [invocation invoke];
    

//    struct MonkeyInfo *tempMonkey ;
    struct MonkeyInfo tempMonkey = {100, "猴哥", "猴王"};
    NSLog(@"tempMonkey.name = %s \n tempMonkey.index = %@", tempMonkey.name, @(tempMonkey.index));
    
    /**< 测试sorcket */
    [self testSorcket];
}

- (UIButton *)tempBtn

{
    if (!_tempBtn) {
        _tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tempBtn setTitle:@"" forState:UIControlStateNormal];
        [_tempBtn  addTarget:self action:@selector(actionTempBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tempBtn;
}

- (void)actionTempBtn:(id)sender
{
    
}




#pragma mark -------------------------------------------------------------------------------------------
/**< 测试sorcket */
- (void)testSorcket{
    
    /**< 第二步 定义套接字 */
    /*
    *pragma adress_family - 协议族  (AF_INET : ipv4; AF_INET6 : ipv6)
    *pragma 数据格式 - SOCK_STREAM(TCP)/SOCK_DGRAM(UDP)
    *pragma protocol - IPPROTO_TCP(tcp), 如果传入0,会自动根据传入的第二个参数,选中合适的协议
    */
    self.client_socket = socket(AF_INET, SOCK_STREAM, 0);
    
    /*
     *pragma 客户端socket
     *pragma 指向数据结构 socketAddr 的指针, 其中包括目的端口和ip地址
     *pragma 结构体数据长度
     *pragma 返回值 0: 成功,   其他错误代码
     */
    
    struct sockaddr_in sAddr = {0};
    sAddr.sin_family = AF_INET;
    sAddr.sin_port = htons(server_port);
    inet_aton(server_ip, &sAddr.sin_addr);
    sAddr.sin_len = sizeof(sAddr);
    
       
    /**< 第三步 建立连接 */
    int connectFlag = connect(self.client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr));
    if (connectFlag == 0) {
        NSLog(@"成功");
        NSThread *tempThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveData) object:nil];
        [tempThread start];
    }else{
        NSLog(@"失败");
    }
    
    
}

- (void)receiveData
{
    /*
     *pragma 客户端 - socket
     *pragma 接受内容缓冲区域
     *pragma 接受内容缓冲区长度
     *pragma 接受方式 0: 表示阻塞, 必须等服务器返回数据
     *pragma 返回值  成功: 返回写入字节数   失败SOCKET_ERROR
     */
    while (1) {
        char receive_msg[1024] = {0};
        long long result = recv(self.client_socket, receive_msg, sizeof(receive_msg), 0);
        NSLog(@"%s\n",receive_msg);
        /**< 断开或者失败 */
        if (result == 0 || result == -1) {
            close(self.client_socket);
            NSLog(@"socket 断开连接\n%lld",result);
            return;
        }
    }
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

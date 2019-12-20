### 前沿

>市面上的推送有很多：极光推送，个推，这是我用过的两款产品，在推送领域都有特点，现在自己开发了一款推送产品MagotanPush，服务端用Node.js语言，移动端用OC，目前是一个初品，也可以商用哈。

#### 1.推送实现流程
![推送实现流程.png](https://upload-images.jianshu.io/upload_images/1745735-4db4a8106edf5a15.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### 说明：
>第一步：App注册通知，获得DeviceToken，上报apns服务
第二步：App注册通知，获取到DeviceToken，上报自己服务器，作为用户标识
第三步：配置证书和推送文本，根据DeviceToken进行推送
第四步：APNS服务收到消息，完成特定用户的推送

### 2.证书配置

###### 2.1.证书配置
> 网上一大堆，这个我不提供，我相信各位大佬的水平

###### 2.2.pem文件生成

>1.打开钥匙串，选择需要生成的推送证书；

>2.分别将certificate和private key导出得到对应的.p12文件，证书->apns-dev-cert.p12，秘钥->apns-dev-key.p12；

>3.将apns-dev-cert.p12和apns-dev-key.p12文件对应转化为apns-dev-cer.pem和apns-dev-key.pem文件;
```
openssl pkcs12 -clcerts -nokeys -out apns-dev-cert.pem -in apns-dev-cert.p12
openssl pkcs12 -nocerts -out apns-dev-key.pem -in apns-dev-key.p12
```
4.将apns-dev-cert.pem和apns-dev-key.pem文件合成为apns-dev.pem文件
```
cat apns-dev-cert.pem apns-dev-key.pem > apns-dev.pem
```

5.测试证书有效性
```
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert apns-dev-cert.pem -key apns-dev-key.pem
```
>6.终端最后显示以下内容，表示配置pem文件成功

![证书有效.png](https://upload-images.jianshu.io/upload_images/1745735-8d2996a0873584da.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 3 iOS端配置

#### 3.1.项目代码编写

```
#import <UserNotifications/UserNotifications.h>
```

###### 3.1.1.注册推送/获取deviceToken
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//注册推送
UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
// 必须写代理，不然无法监听通知的接收与点击
center.delegate = self;
[center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
if (granted) {
// 点击允许
NSLog(@"注册成功");
[center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
NSLog(@"%@", settings);
}];
} else {
// 点击不允许
NSLog(@"注册失败");
}
}];
//获取deviceToken
[application registerForRemoteNotifications];
return YES;
}
```

###### 3.1.2. iOS 10收到通知

```
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{

NSDictionary * userInfo = notification.request.content.userInfo;
UNNotificationRequest *request = notification.request; // 收到推送的请求
UNNotificationContent *content = request.content; // 收到推送的消息内容
NSNumber *badge = content.badge;  // 推送消息的角标
NSString *body = content.body;    // 推送消息体
UNNotificationSound *sound = content.sound;  // 推送消息的声音
NSString *subtitle = content.subtitle;  // 推送消息的副标题
NSString *title = content.title;  // 推送消息的标题

if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
}else {
// 判断为本地通知
NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
}
completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置，Alert可以设定前台展示通知栏。
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
//处理推送过来的数据
NSLog(@"%@",response.notification.request.content.userInfo);
completionHandler();
}
```
###### 3.1.3.将得到的deviceToken传给SDK
```
// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
NSLog(@"deviceTokenStr:\n%@",deviceTokenStr);
[[NSUserDefaults standardUserDefaults] setValue:deviceTokenStr forKey:@"DEVICETOKEN"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{

NSLog(@"注册推送失败Error：%@",error.localizedDescription);
}
```

#### 4.服务端集成
```
"use strict";

const apn = require("apn");

// deviceToken 数组
let tokens = ["7f56110923c266397a3aa434ce15d3172b5666b98f49543cd78fc45e682f55b4"];

let service = new apn.Provider({
cert: "apns-dev-cert.pem",
key: "apns-dev-key.pem",
gateway: "gateway.sandbox.push.apple.com",
// gateway: "gateway.push.apple.com"; //线上地址
// port: 2195, //端口
passphrase: "关注公众号，找我要密码，hahah" //pem证书密码
});

let note = new apn.Notification();

note.payload = {
from : "MagotanPush_APNS",
source : "ios",
module : "home"
};

note.body = "Hello MagotanPush!";

// 主题 一般取应用标识符（bundle identifier）
note.topic = "geekschen.APNsTest"

console.log(`Sending: ${note.compile()} to ${tokens}`);
service.send(note, tokens).then( result => {
console.log("sent:", result.sent.length);
console.log("failed:", result.failed.length);
console.log(result.failed);
});

service.shutdown();
```

#### 5.效果展示
##### server:
![服务端操作.png](https://upload-images.jianshu.io/upload_images/1745735-4690b1c01c2c8c42.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### client:
![客户端效果.jpeg](https://upload-images.jianshu.io/upload_images/1745735-37de3039bf260f94.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


个人作品1：（匿名聊天）
[http://im.meetyy.cn/](http://im.meetyy.cn/)

个人作品2：（单身交友）
![公众号Meetyy](https://upload-images.jianshu.io/upload_images/1745735-9ba29c862a0268be.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



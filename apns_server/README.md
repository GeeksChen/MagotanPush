###### 测试环境调试iOS的APNS服务时，可以使用nodejs

需要Mac支持Node js，如果没有安转Node环境可以自行查阅如何安转。
> 如何写调试js文件:

1.下载推送代码[iOSPush](https://github.com/xlsd/iOSPush)

2.其中需要`.pem`和`.pkey`文件，将配置好的推送证书放在该目录下。![image.png](https://upload-images.jianshu.io/upload_images/2276492-2600b14649a55830.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.使用文本编辑器如Sublime打开`APNS.js`文件。

![image.png](https://upload-images.jianshu.io/upload_images/2276492-a118b04a3e7c51ba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

①需要替换成自己手机的deviceToken(是`NSString`类型而不是`NSData`)

②填写`.pem`和`.pkey`

③按照`APNS`的要求填写对应的字段内容


##推送的格式如下(照抄自苹果)
## Class: apn.Notification

A `Notification` encapsulates data to be sent to a device and handles JSON encoding for transmission. See the [payload documentation][pl] for more details.

### Initialization

When initializing a `Notification` you can optionally pass an object to pre-populate properties as they are defined below.

```javascript
let notification = new apn.Notification({
  alert: "Hello, world!",
  sound: "chime.caf",
  mutableContent: 1,
  payload: {
    "sender": "node-apn",
  },
});
```

### Payload

#### `notification.payload`

This `Object` is JSON encoded and sent as the notification payload. When properties have been set on `notification.aps` (either directly or with convenience setters) these are added to the `payload` just before it is sent. If `payload` already contains an `aps` property it is replaced.

**Example:**

```javascript
let notification = new apn.Notification();

notification.payload = {
  from: "node-apn",
  source: "web",
};

notification.body = "Hello, world!";
```

**Output:**

```json
{
  "from":"node-apn",
  "source":"web",
  "aps":{
    "alert":"Hello, world!"
  }
}
```

#### `notification.rawPayload`

If supplied this payload will be encoded and transmitted as-is. The convenience setters will have no effect on the JSON output.

**Example:**

```javascript
let notification = new apn.Notification();

notification.rawPayload = {
  from: "node-apn",
  source: "web",
  aps: {
    "content-available": 1
  }
};

notification.body = "Hello, world!";
```

**Output:**

```json
{
  "from":"node-apn",
  "source":"web",
  "aps":{
    "content-available":1
  }
}
```

### Convenience Setters

The setters below provide a cleaner way to set properties defined by the Apple Push Notification Service (APNS).

This table shows the name of the setter, with the key-path of the underlying property it maps to and the expected value type.

| Setter Name         | Target Property             | Type                |
|---------------------|-----------------------------|---------------------|
| `alert`             | `aps.alert`                 | `String` or `Object`|
| `body`              | `aps.alert.body`            | `String`            |
| `locKey`            | `aps.alert.loc-key`         | `String`            |
| `locArgs`           | `aps.alert.loc-args`        | `Array`             |
| `title`             | `aps.alert.title`           | `String`            |
| `titleLocKey`       | `aps.alert.title-loc-key`   | `String`            |
| `titleLocArgs`      | `aps.alert.title-loc-args`  | `Array`             |
| `action`            | `aps.alert.action`          | `String`            |
| `actionLocKey`      | `aps.alert.action-loc-key`  | `String`            |
| `launchImage`       | `aps.launch-image`          | `String`            |
| `badge`             | `aps.badge`                 | `Number`            |
| `sound`             | `aps.sound`                 | `String`            |
| `contentAvailable`  | `aps.content-available`     | `1`                 |
| `mutableContent`    | `aps.mutable-content`       | `1`                 |
| `urlArgs`           | `aps.url-args`              | `Array`             |
| `category`          | `aps.category`              | `String`            |
| `threadId`          | `aps.thread-id`             | `String`            |
| `mdm`               | `mdm`                       | `String`            |

When the notification is transmitted these properties will be added to the output before encoding.

For each convenience setter there is also a chainable method which invokes the setter and returns `this`. These are predictably named: `propertyName -> setPropertyName()`.

It is also possible to set properties directly on `aps` if the setters above do not meet your needs.

**Example:**
```javascript
let notification    = new apn.Notification();

/// Convenience setter
notification.body   = "Hello, world!";
notification.title  = "node-apn";
notification.badge  = 10;

/// Chainable setter
notification.setAction("npm install")
            .setMutableContent(1);

/// Direct `aps` property access
notification.aps.category = "nodejs";
```

**Output:**

```json
{
  "aps":{
    "alert":{
      "body":"Hello, world!",
      "title":"node-apn",
      "action":"npm install"
    },
    "badge":10,
    "mutable-content": 1,
    "category":"nodejs"
  }
}
```

### Properties

The properties below are sent alongside the notification as configuration and do not form part of the JSON payload. As such, they are not counted against the payload size limit.

#### notification.topic

_Required_: The destination topic for the notification.

#### notification.id

A UUID to identify the notification with APNS. If an `id` is not supplied, APNS will generate one automatically. If an error occurs the response will contain the `id`. This property populates the `apns-id` header.

#### notification.expiry

A UNIX timestamp when the notification should expire. If the notification cannot be delivered to the device, APNS will retry until it expires. An expiry of `0` indicates that the notification expires immediately, therefore no retries will be attempted.

#### notification.priority

Provide one of the following values:

  * `10` - The push notification is sent to the device immediately. (Default)
    > The push notification must trigger an alert, sound, or badge on the device. It is an error to use this priority for a push notification that contains only the `content-available` key.
  * `5` - The push message is sent at a time that conserves power on the device receiving it.


#### notification.collapseId

Multiple notifications with same collapse identifier are displayed to the user as a single notification. The value should not exceed 64 bytes.

[pl]:https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html "Local and Push Notification Programming Guide: Apple Push Notification Service"

> 如何使用

* 打开终端，`cd`命令到指定下载的文件夹的根目录。
* 使用`node`命令运行`APNS.js`文件，如`node APNS.js`。
推送即可。
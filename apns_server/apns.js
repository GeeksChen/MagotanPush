"use strict";

const apn = require("apn");

// deviceToken 数组
let tokens = ["7f56110923c266397a3aa434ce15d3172b5666b98f49543cd78fc45e682f55b4"];

let service = new apn.Provider({
  cert: "apns-dev-cert.pem",//大佬们自行替换
  key: "apns-dev-key.pem", //大佬们自行替换
  gateway: "gateway.sandbox.push.apple.com",
  // gateway: "gateway.push.apple.com"; //线上地址
  // port: 2195, //端口
  passphrase: "关注公众号找我要密码，hahah" //pem证书密码
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
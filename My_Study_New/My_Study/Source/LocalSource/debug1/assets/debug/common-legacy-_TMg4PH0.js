System.register(["./vendor-legacy-u5ulrW0q.js"],(function(e,t){"use strict";var a;return{setters:[function(e){a=e.c}],execute:function(){e({a:function(e){for(var t=arguments.length,l=new Array(t>1?t-1:0),i=1;i<t;i++)l[i-1]=arguments[i];a(e,l),console.log(e,":",l)},d:function(e){a("dial",e)},g:function(){var e="ph_user_info",t=sessionStorage.getItem(e);return t?Promise.resolve(JSON.parse(t)):new Promise((function(t){a("getUserInfo",(function(a){var l=JSON.stringify(a);sessionStorage.setItem(e,l),t(a)}))}))}}),e("b",(function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:window.location.href;return new URL(t).searchParams.get(e)||""})),e("e",(function(e,t){var a=new URL(window.location.href);a.searchParams.set(e,t),window.history.pushState({},"",a.toString())})),e("s",[{title:"单个Webview跳转",name:"forward",params:{url:"https://m.lu.com",setStyle:!0,needFinish:!0}},{title:"单个WebView内跳转",name:"forwardInside",params:{url:"/hybrid/debug.html#/user",setStyle:!0,data:"{}"}},{title:"跳转到另一个模块的页面",name:"forwardModule",params:{url:"/hybrid/debug.html#/webview",setStyle:!0,needFinish:!0}},{title:"设置header样式",name:"setHeadStyle",params:{setStyle:!0}},{title:"设置header",name:"setHeader",params:{title:"设置header",isBack:!0,backCallback:function(){console.log(1)},rightText:"right"}},{title:"关闭当前界面",name:"finishNowActivity",params:{}},{title:"向前跳转到隐私协议界面",name:"turnPrivacyPage",params:{title:"隐私协议",url:"/hybird/debug.html#/index"}},{title:"获取当前App使用语言",name:"getAppLanguage",params:{callback:function(e){console.log(e)}}},{title:"获取当前用户的登录信息",name:"getUserInfo",params:{callback:function(e){console.log(e)}}},{title:"获取APP版本信息",name:"getAppVersion",params:{callback:function(e){console.log(e)}}},{title:"登录超时接口",name:"dealTimeOut",params:{callback:function(e){console.log(e)}}},{title:"判断是否登录",name:"isLogined",params:{callback:function(e){console.log(e)}}},{title:"退出登录",name:"logout",params:{callback:function(e){console.log(e)}}},{title:"进入拨号页面",name:"dialPhone",params:{phoneNum:"021-123456789"}},{title:"存储全局数据",name:"setLocalStorage",params:{key:"global-key",value:'{"a":1}'}},{title:"获取全局数据",name:"getLocalStorage",params:{key:"global-key",callback:function(e){console.log(e)}}},{title:"删除全局数据",name:"removeLocalStorage",params:{key:"global-key"}},{title:"复制文字到剪贴板",name:"copyText",params:{text:"复制复制粘贴粘贴"}},{title:"获取设备信息和GPS信息",name:"getDeviceInfo",params:{text:"global-key"}},{title:"加载网页链接",name:"loadingWebPage",params:{title:"加载网页链接",linkUrl:"https://m.lu.com",setStyle:!0}}]),e("m",[{title:"系统",type:"system",children:[{title:"获取当前设备信息",name:"get_app"},{title:"修改导航栏标题",name:"set_navbar",params:["left","leftCallback","right","rightCallback"]},{title:"修改导航栏样式",name:"set_header",params:["color","backgroundColor","isImmersive"]},{title:"上传",name:"uploader",params:["images","camera","file"]},{title:"webview状态",name:"webview",params:["onViewBack","onViewAppear","onViewUnAppear"]}]},{title:"用户",type:"user",children:[{title:"获取用户信息",name:"getUserInfo"},{title:"跳转登陆页",name:"login"},{title:"登出",name:"logout"},{title:"拨打电话",name:"tel",params:["1234567890"]}]},{title:"webview",type:"webview",children:[{title:"新开webview, 支持hybrid页面",name:"push_view",params:{url:""}},{title:"回退webview",name:"pop_view"},{title:"关闭全部webview并回到首页",name:"close_view"}]}]),e("c",{getApp:"get_app",setNavbar:"set_navbar",setHeader:"set_header",uploader:"uploader",webview:"webview",getUserInfo:"getUserInfo",login:"login",logout:"logout",tel:"tel",pushView:"push_view",popView:"pop_view",closeView:"close_view"})}}}));

!function(){function n(n,e){return function(n){if(Array.isArray(n))return n}(n)||function(n,t){var e=null==n?null:"undefined"!=typeof Symbol&&n[Symbol.iterator]||n["@@iterator"];if(null!=e){var r,o,l,i,c=[],u=!0,a=!1;try{if(l=(e=e.call(n)).next,0===t){if(Object(e)!==e)return;u=!1}else for(;!(u=(r=l.call(e)).done)&&(c.push(r.value),c.length!==t);u=!0);}catch(n){a=!0,o=n}finally{try{if(!u&&null!=e.return&&(i=e.return(),Object(i)!==i))return}finally{if(a)throw o}}return c}}(n,e)||function(n,e){if(!n)return;if("string"==typeof n)return t(n,e);var r=Object.prototype.toString.call(n).slice(8,-1);"Object"===r&&n.constructor&&(r=n.constructor.name);if("Map"===r||"Set"===r)return Array.from(n);if("Arguments"===r||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(r))return t(n,e)}(n,e)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function t(n,t){(null==t||t>n.length)&&(t=n.length);for(var e=0,r=new Array(t);e<t;e++)r[e]=n[e];return r}System.register(["./vendor-legacy-u5ulrW0q.js","./common-legacy-_TMg4PH0.js"],(function(t,e){"use strict";var r,o,l,i,c,u,a,s,f,d;return{setters:[function(n){r=n.u,o=n.d,l=n.e,i=n.j,c=n.N,u=n.B,a=n.c},function(n){s=n.c,f=n.g,d=n.d}],execute:function(){var e=document.createElement("style");e.textContent=".show-content{padding:20px}\n",document.head.appendChild(e),t("default",(function(){var t=r().state,e=t.title,g=void 0===e?"":e,h=t.name,y=void 0===h?"":h,m=n(o.useState(g),1)[0],j=n(o.useState(!1),2),v=j[0],x=j[1],p=n(o.useState("test user"),2),b=p[0],S=p[1];l({titleText:m});return i.jsxs(i.Fragment,{children:[i.jsx(c,{onBack:function(){window.history.go(-1)},children:m}),i.jsxs("div",{className:"show-content",children:[y===s.getUserInfo?i.jsx(i.Fragment,{children:v?i.jsxs(i.Fragment,{children:["用户信息:",b]}):i.jsx(u,{onClick:function(){x(!0),f().then((function(n){S(n)}))},children:"获取用户信息"})}):null,y===s.login?i.jsx(u,{onClick:function(){a(s.login,(function(){console.log("goto login.")}))},children:"跳转登录页"}):null,y===s.logout?i.jsx(u,{onClick:function(){a(s.logout,(function(){console.log("goto logout.")}))},children:"跳转登出页"}):null,y===s.tel?i.jsx(u,{onClick:function(){d("021-1234567890")},children:"拨打电话"}):null]})]})}))}}}))}();

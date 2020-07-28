(function (win) {
    /**
     * 观察者模式实现事件监听
     */
    function Observer() {
        this._eventsList = {}; // 对外发布的事件列表{"connect" : [{fn : null, scope : null}, {fn : null, scope : null}]}
    }

    Observer.prototype = {
        // 空函数
        _emptyFn: function () {
        },
        /**
         * 判断事件是否已发布
         * @param eType 事件类型
         * @return Boolean
         */
        _hasDispatch: function (eType) {
            eType = (String(eType) || '').toLowerCase();
            return "undefined" !== typeof this._eventsList[eType];
        },

        /**
         * 根据事件类型查对fn所在的索引,如果不存在将返回-1
         * @param eType 事件类型
         * @param fn 事件句柄
         */
        _indexFn: function (eType, fn) {
            if (!this._hasDispatch(eType)) {
                return -1;
            }
            var list = this._eventsList[eType];
            fn = fn || '';
            for (var i = 0; i < list.length; i++) {
                var dict = list[i];
                var _fn = dict.fn || '';
                if (fn.toString() === _fn.toString()) {
                    return i;
                }
            }
            return -1;
        },

        /**
         * 创建委托
         */
        createDelegate: function () {
            var __method = this;
            var args = Array.prototype.slice.call(arguments);
            var object = args.shift();
            return function () {
                return __method.apply(object, args.concat(Array.prototype.slice.call(arguments)));
            }
        },

        /**
         * 发布事件
         */
        dispatchEvent: function () {
            if (arguments.length < 1) {
                return false;
            }
            var args = Array.prototype.slice.call(arguments), _this = this;
            for (var i = 0; i < args.length; i++) {
                var eType = args[i];
                if (_this._hasDispatch(eType)) {
                    return true;
                }
                _this._eventsList[eType.toLowerCase()] = [];
            }
            return this;
        },

        /**
         * 触发事件
         */
        emit: function () {
            if (arguments.length < 1) {
                return false;
            }
            var args = Array.prototype.slice.call(arguments), eType = args.shift().toLowerCase(), _this = this;
            if (this._hasDispatch(eType)) {
                var list = this._eventsList[eType];
                if (!list) {
                    return this;
                }
                for (var i = 0; i < list.length; i++) {
                    var dict = list[i];
                    var fn = dict.fn, scope = dict.scope || _this;
                    if (!fn || "function" !== typeof fn) {
                        fn = _this._emptyFn;
                    }
                    if (true === scope) {
                        scope = null;
                    }
                    fn.apply(scope, args);
                }
            }
            return this;
        },

        /**
         * 订阅事件
         * @param eType 事件类型
         * @param fn 事件句柄
         * @param scope
         */
        on: function (eType, fn, scope) {
            eType = (eType || '').toLowerCase();
            if (!this._hasDispatch(eType)) {
                throw new Error("not dispatch event " + eType);
                return false;
            }
            this._eventsList[eType].push({ fn: fn || null, scope: scope || null });
            return this;
        },

        /**
         * 取消订阅某个事件
         * @param eType 事件类型
         * @param fn 事件句柄
         */
        un: function (eType, fn) {
            eType = (eType || '').toLowerCase();
            if (this._hasDispatch(eType)) {
                var index = this._indexFn(eType, fn);
                if (index > -1) {
                    var list = this._eventsList[eType];
                    list.splice(index, 1);
                }
            }
            return this;
        },

        /**
         * 取消订阅所有事件
         */
        die: function (eType) {
            eType = (eType || '').toLowerCase();
            if (this._eventsList[eType]) {
                this._eventsList[eType] = [];
            }
            return this;
        }
    };

    var cache = {};
    var isReady = false;
    var u = navigator.userAgent;
    var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1; //android终端
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/); //ios终端
    var readyCallBackFun;

    //HTML5开放API
    var api = {

        version: '0.0.22',
        /**
         * 加载完成触发
         * @param cb
         */
        ready: function (cb) {
            readyCallBackFun = cb;
        },
        /**
         * 配置右上角菜单,传递一个字符串数组
         * WeChatSession 微信好友
         * WeChatTimeline 微信朋友圈
         * TencentQQFriend QQ好友(暂时不支持)
         * TencentQZone  QQ空间(暂时不支持)
         * IntraoralFriend 好班好友
         * IntraoralSession 好班聊天
         * AgencyHomePage 机构首页
         */
        configMenus: function (options) {
            if (!isReady) return;
            options = options || [];
            if (isiOS) {
                window.webkit.messageHandlers.configMenus.postMessage(options);
            } else if (isAndroid) {
                tsingdaJSBridge.configMenus(options);
            }
        },

        /**
         * 是否显示右上角分享菜单
         */
        displayMenusButton: function (show) {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.displayMenusButton.postMessage(show);
            } else if (isAndroid) {
                tsingdaJSBridge.displayMenusButton(show);
            }
        },

        /**
         * 设置是否开启自动分享功能
         * 默认是true,客户端点击分享菜单上的按钮后会自动连接第三方工具进行分享
         * 如果设置为false,客户端点击分享菜单上的按钮后，只会触发点击事件,具体的分享有H5调用其它方法完成
         */
        autoShared: function (auto) {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.autoShared.postMessage(auto);
            } else if (isAndroid) {
                tsingdaJSBridge.autoShared(auto);
            }
        },

        /**
         * 分享到XXX
         */
        sendShared: function (type, options) {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.sendShared.postMessage({ type: type, options: options });
            } else if (isAndroid) {
                tsingdaJSBridge.sendShared(JSON.stringify({ type: type, options: options }));
            }
            // eo.on('TsingdaJSBridgeEventOnSharedSuccess', success);
            // eo.on('TsingdaJSBridgeEventOnSharedFailure', failure);
        },

        /**
         * 注册分享到朋友圈内容
         * @param type 分享类型,和菜单类型对应
         * @param options JSON对象
         * {
         *    title: "abc", // 分享标题
         *    desc: "哈哈哈",
         *    link: "http://www.baidu.com", // 分享链接
         *    imageUrl: "http://www.baodiu.com/1.jpg", // 分享图标
         * }
         * @param success 分享成功时回调方法
         * @param failure 分享失败时回调方法
         */
        share: function (type, options, success, failure) {
            if (!isReady) return;
            options = options || {};
            cache[type] = {
                data: options,
                success: success,
                failure: failure
            }
        },
        /**
         * 弹出分享菜单
         */
        openShareAlert: function () {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.openShareAlert.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.openShareAlert();
            }
        },
        /**
         * 支付
         * @param type 支付类型 (wxpay,alipay)
         * @param options 支付配置(待定)
         * 微信支付配置 {
         *    partnerId: "", //商家向财付通申请的商家id
         *    prepayId: "", //预支付订单
         *    nonceStr: "", //随机串，防重发
         *    timeStamp: "", //时间戳，防重发
         *    package: "", //商家根据财付通文档填写的数据和签名
         *    sign: "" //商家根据微信开放平台文档对数据做的签名
         * }
         * @param success  支付完成回调方法,回调会把传进来的参数原路返回,也是一个JSON对象
         * @param failure  支付失败回调方法,会返回出错的字符串信息
         */
        payment: function (type, options, success, failure) {
            if (!isReady) return;
            if (success) {
                eo.on('TsingdaJSBridgeEventOnPaymentSuccess', function (res) {
                    success(res);
                    eo.un('TsingdaJSBridgeEventOnPaymentSuccess');
                });
            }
            if (failure) {
                eo.on('TsingdaJSBridgeEventOnPaymentFailure', function (err) {
                    failure(err);
                    eo.un('TsingdaJSBridgeEventOnPaymentFailure');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.payment.postMessage({
                    type: type,
                    options: options
                });
            } else if (isAndroid) {
                win.tsingdaJSBridge.payment(type, JSON.stringify(options || {}));
            }
        },
        /**
         * 日志输出
         */
        log: function (str) {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.log.postMessage(str);
            } else if (isAndroid) {
                win.tsingdaJSBridge.log(str);
            }
        },
        /**
         * 返回上一级页面
         */
        goBack: function () {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.goBack.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.goBack();
            }
        },
        /**
         * 打开聊天会话
         * @param userID 用户唯一ID
         * @param option 与店主聊天时，自动创建一条产品相关的聊天信息
         * {
         *    title: "abc", // 分享标题
         *    desc: "哈哈哈",
         *    link: "http://www.baidu.com", // 分享链接
         *    imageUrl: "http://www.baodiu.com/1.jpg", // 分享图标
         * }
         */
        openChatSession: function (toUserId, option) {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.openChatSession.postMessage({ userId: toUserId, option: option || {} });
            } else if (isAndroid) {
                win.tsingdaJSBridge.openChatSession(toUserId, JSON.stringify(option || {}));
            }
        },
        /**
         * 打开商城列表
         */
        openMallList: function () {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.openMallList.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.openMallList();
            }
        },
        /**
         * 获取登录状态
         * @param callback 回调方法
         *
         * @callback 回调方法
         * @param {Number} state  1=登录,0=未登录
         */            
        fetchUserLoginState: function (callback) {
            if (!isReady) return;
            if (callback) {
                eo.on('TsingdaJSBridgeEventOnUserLoginStatSuccess', function (deviceId) {
                    callback(deviceId);
                    eo.die('TsingdaJSBridgeEventOnUserLoginStatSuccess');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.fetchUserLoginState.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.fetchUserLoginState();
            }
        },
        /**
         * 打开登录窗口
         */
        openLogin: function () {
            if (!isReady) return;
            if (isiOS) {
                window.webkit.messageHandlers.openLogin.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.openLogin();
            }
        },
        /**
         * 打开二维码扫描
         * @param successCallback 回调方法
         *
         * @callback 回调方法
         * @param {string} str 二维码对应的字符串
         */
        openQR: function (successCallback) {
            if (!isReady) return;
            if (successCallback) {
                eo.on('TsingdaJSBridgeEventOnQRSuccess', function (str) {
                    successCallback(str);
                    eo.un('TsingdaJSBridgeEventOnQRSuccess');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.openQR.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.openQR();
            }
        },
        /**
         * 获取当前位置信息
         * @param callback 回调方法
         *
         * @callback 回调方法
         * @param {JSON} data 获取到的地理位置信息,这是一个JSON对象
         * @param {JSON} data.location  经纬度
         * @param {Number} data.location.longitude 经度
         * @param {Number} data.location.latitude  纬度
         * @param {JSON} data.area            位置信息
         * @param {String} data.area.country  国家
         * @param {String} data.area.city     城市
         * @param {String} data.area.province 省份
         * @param {String} data.area.district 区县
         * @param {String} data.area.street   街道
         * @param {String} data.area.name     具体地标
         */
        location: function (callback) {
            if (!isReady) return;
            if (callback) {
                eo.on('TsingdaJSBridgeEventOnLocationSuccess', function (data) {
                    callback(data);
                    eo.un('TsingdaJSBridgeEventOnLocationSuccess');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.location.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.location();
            }
        },
        /**
         * 打开系统相册
         * @param maxSelectedCount 最大选择图片数量
         * @param callback 回调方法
         *
         * @callback 回调方法
         * @param {Array} urls 图片上传到服务器后的url地址集合
         */
        openAlbum: function (maxSelectedCount, callback) {
            if (!isReady) return;
            if (callback) {
                eo.on('TsingdaJSBridgeEventOnOpenAlbumSuccess', function (urls) {
                    callback(urls);
                    eo.un('TsingdaJSBridgeEventOnOpenAlbumSuccess');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.openAlbum.postMessage(maxSelectedCount);
            } else if (isAndroid) {
                win.tsingdaJSBridge.openAlbum(maxSelectedCount);
            }
        },
        /**
         * 获取设备ID
         * @param callback 回调方法
         * @callback 回调方法
         * @param {String} deviceId 设备ID
         */
        fetchDeviceID: function (callback) {
            if (!isReady) return;
            if (callback) {
                eo.on('TsingdaJSBridgeEventOnFetchDeviceIDSuccess', function (deviceId) {
                    callback(deviceId);
                    eo.un('TsingdaJSBridgeEventOnFetchDeviceIDSuccess');
                });
            }
            if (isiOS) {
                window.webkit.messageHandlers.fetchDeviceID.postMessage(null);
            } else if (isAndroid) {
                win.tsingdaJSBridge.fetchDeviceID();
            }
        }
    };

    function uuid(len, radix) {
        var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
        var uuid = [], i;
        radix = radix || chars.length;

        if (len) {
            // Compact form
            for (i = 0; i < len; i++) uuid[i] = chars[0 | Math.random() * radix];
        } else {
            // rfc4122, version 4 form
            var r;

            // rfc4122 requires these characters
            uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
            uuid[14] = '4';

            // Fill in random data. At i==19 set the high bits of clock sequence as
            // per rfc4122, sec. 4.1.5
            for (i = 0; i < 36; i++) {
                if (!uuid[i]) {
                    r = 0 | Math.random() * 16;
                    uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
                }
            }
        }

        return uuid.join('');
    }

    var store = {
        set: function (key, value, callback) {
            if (!isReady) return;
            if (key === undefined || value === undefined) { return }
            var r = uuid(8, 16);
            var e = 'TsingdaJSBridgeEventOnStoreSetValueSuccess_' + r;
            if (callback) {
                eo.dispatchEvent(e);
                eo.on(e, function (result) {
                    callback(result.key, result.value);
                    eo.die(e);
                });
            }
            var request_data = { key: key, value: value, e: e };
            if (isiOS) {
                window.webkit.messageHandlers.storeSet.postMessage(request_data);
            } else if (isAndroid) {
                tsingdaJSBridge.storeSet(JSON.stringify(request_data));
            }
        },
        get: function (key, callback) {
            if (!isReady) return;
            if (key === undefined) { return }
            var r = uuid(8, 16);
            var e = 'TsingdaJSBridgeEventOnStoreGetValueSuccess' + r;
            if (callback) {
                eo.dispatchEvent(e);
                eo.on(e, function (result) {
                    callback(result ? result.key : key, result ? result.value : null);
                    eo.die(e);
                });
            }
            var request_data = { key: key, e: e };
            if (isiOS) {
                window.webkit.messageHandlers.storeGet.postMessage(request_data);
            } else if (isAndroid) {
                tsingdaJSBridge.storeGet(JSON.stringify(request_data));
            }
        },
        remove: function (key, callback) {
            if (!isReady) return;
            if (key === undefined) { return }
            var r = uuid(8, 16);
            var e = 'TsingdaJSBridgeEventOnStoreRemoveValueSuccess' + r;
            if (callback) {
                eo.dispatchEvent(e);
                eo.on(e, function () {
                    callback();
                    eo.die(e);
                });
            }
            var request_data = { key: key, e: e };
            if (isiOS) {
                window.webkit.messageHandlers.storeRemove.postMessage(request_data);
            } else if (isAndroid) {
                tsingdaJSBridge.storeRemove(JSON.stringify(request_data));
            }
        },
        clear: function (callback) {
            if (!isReady) return;
            var r = uuid(8, 16);
            var e = 'TsingdaJSBridgeEventOnStoreClearValueSuccess' + r;
            if (callback) {
                eo.dispatchEvent(e);
                eo.on(e, function () {
                    callback();
                    eo.die(e);
                });
            }
            var request_data = { e: e };
            if (isiOS) {
                window.webkit.messageHandlers.storeClear.postMessage(request_data);
            } else if (isAndroid) {
                tsingdaJSBridge.storeClear(JSON.stringify(request_data));
            }
        }
    }

    //生成事件对象
    var eo = new Observer();
    //添加事件,交互对象已准备完成
    eo.dispatchEvent('TsingdaJSBridgeEventOnReady');
    eo.dispatchEvent('TsingdaJSBridgeEventOnPaymentSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnPaymentFailure');
    eo.dispatchEvent('TsingdaJSBridgeEventOnMenusClickItem');
    eo.dispatchEvent('TsingdaJSBridgeEventOnSharedSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnSharedFailure');
    eo.dispatchEvent('TsingdaJSBridgeEventOnQRSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnLocationSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnOpenAlbumSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnFetchDeviceIDSuccess');
    eo.dispatchEvent('TsingdaJSBridgeEventOnUserLoginStatSuccess');

    eo.on('TsingdaJSBridgeEventOnReady', function () {
        isReady = true;
        if (readyCallBackFun) {
            readyCallBackFun();
        }
        eo.un('TsingdaJSBridgeEventOnReady', this);
    });

    api.cache = cache;
    api.event = eo;
    api.store = store;
    win.tsingda = api;
}(this));

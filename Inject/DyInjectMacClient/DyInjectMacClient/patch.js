
require('UIApplication,__DyViewManager,NSIndexPath,NSMutableArray,UIColor,WCNewCommitViewController,MMUINavigationController,WCContentItemViewTemplateGrid,MMPickLocationViewController');
defineClass('__DyJsBridge', {
            dyJsMethod: function() {
            var keyWindow = UIApplication.sharedApplication().keyWindow();
            var rootViewController = keyWindow.rootViewController();
            if (rootViewController.isKindOfClass(require("UITabBarController").class()))
            {
            var vcs = rootViewController.viewControllers();
            
            for (var i = 0;i < vcs.count();i ++)
            {
            var nc = vcs.objectAtIndex(i);
            console.log(nc.visibleViewController());
            }
            
            }
//            var window = UIApplication.sharedApplication().windows();
//            console.log(window);
//            for (var i = 0;i < window.count();i ++)
//            {
//                var tempWindow = window.objectAtIndex(i);
//            if(tempWindow.rootViewController().isKindOfClass(require("UINavigationController").class()))
//            {
//            console.log("navigation");
//            console.log(__DyViewManager.visibleViewControllerForRootController(tempWindow.rootViewController()));
//            }
//            console.log(tempWindow.rootViewController());
//            }
//            var rootViewController = UIApplication.sharedApplication().keyWindow().rootViewController();
//            var chatVc = __DyViewManager.visibleViewControllerForRootController(rootViewController);
//            
//            var tempValue = chatVc.valueForKey("_lastSelectedLocation");
//            
//            console.log(chatVc.description());
//            if(tempValue == false || tempValue == null)
//            {
//            }else
//                console.log(tempValue.description());
            
            return "mapview";
//            console.log(chatVc.presentedViewController());
//            console.log(chatVc.navigationController().presentedViewController());
//
//            var tempCellArray = chatVc.valueForKey("m_tableView").visibleCells();
//            var tempArray = NSMutableArray.array();
//            for(var i = 0; i < tempCellArray.count();i++)
//            {
//            
//            var cell = tempCellArray.objectAtIndex(i);
//            var timeLineContentView = cell.contentView().subviews().lastObject();
//            if (timeLineContentView.respondsToSelector("m_dataItem"))
//            {
//            var dataItem = timeLineContentView.valueForKey("m_dataItem");//valueForKey("type");
//            var contentItem = dataItem.valueForKey("contentObj");
//            var tempSublistArray = cell.contentView().subviews().lastObject().subviews();
//            for(var j = 0; j < tempSublistArray.count();j++)
//            {
//            var tempSublistView = tempSublistArray.objectAtIndex(j);
//            
//            console.log(tempSublistView.subviews());
//            console.log(tempSublistView)
//            
//            }
//            
//            }
//            }
            
//            return "t";
            },
            });

//initWithScene
//defineClass('UIView', {
//            ____dyOneKeyForward: function() {
//
//            console.log("____dyOneKeyForward");
//            var m_dataItem = self.valueForKey("m_dataItem");
//            var contentItem = m_dataItem.valueForKey("contentObj");
//            var mediaWraps = m_dataItem.getMediaWraps();
//            var firstItemWrap = mediaWraps.firstObject();
//            var mediaItem = firstItemWrap.valueForKey("mediaItem");
//            console.log(mediaItem.pathForPreview());
//            }
//            });
//
defineClass('DyWeChatPickLocation', {
            initWithSourceViewController: function(a) {
            self = self.super().init();
            
            var vc = MMPickLocationViewController.alloc().initWithScene_OnlyUseUserLocation(0,false);
            vc.setDelegate(self);
            
            var nai = MMUINavigationController.alloc().initWithRootViewController(vc);
            self.setViewController(vc);
            a.presentViewController_animated_completion(nai,true,null);
            }
            });
//
//defineClass('BaseMessageNodeView', {
//            showOperationMenu: function() {
//            console.log("showOperationMenu");
//            }
//            });

//defineClass('DownloadImageCDNMgr', {
//            DownloadOK: function() {
//            console.log("DownloadOK");
//            }
//            });

//defineClass('WCDownloadMgr', {
//            doDownloadMediaCDN: function(arg1) {
//            console.log(arg1);
//            var downloadWrap = arg1
//            console.log(downloadWrap.valueForKey("downloadType"))
//            console.log("doDownloadMediaCDN");
//            }
//            });
//
//defineClass('WCDownloadMgr', {
//            downloadMedia_downloadType: function(arg1,arg2) {
//            console.log(arg1);
//            console.log("downloadMedia_downloadType");
//            }
//            });


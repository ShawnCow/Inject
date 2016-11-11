
require('UIApplication,__DyViewManager,NSIndexPath,NSMutableArray');
defineClass('__DyJsBridge', {
            dyJsMethod: function() {
            //            return UIApplication.sharedApplication().windows().description();
            var rootViewController = UIApplication.sharedApplication().keyWindow().rootViewController();
            var chatVc = __DyViewManager.visibleViewControllerForRootController(rootViewController);
            var array = chatVc.valueForKey("m_arrMessageNodeData");
            var tableView = chatVc.valueForKey("m_tableView");
            var resultArray = NSMutableArray.array();
            for(var i = 0 ; i < array.count();i ++)
            {
            var msg = array.objectAtIndex(i);
            var msgType = msg.m__eMsgNodeType();
            if(msgType == 1)
            {
            var msgWarp = msg.m__msgWrap(); //m_uiMessageType
            var warpMsgType = msgWarp.m__uiMessageType();
            if(warpMsgType != null && warpMsgType != false)
            resultArray.addObject(warpMsgType);
            }
            }
            //return resultArray.description();
            //            return chatVc.view().subviews().description();
            //            var tableView = chatVc.valueForKey("m_tableView");//.description();
            return tableView.visibleCells().lastObject().subviews().firstObject().description();
            },
            });

defineClass('BaseMsgContentViewController', {
            dy_addReceiveMessageNode: function(argc) {
            console.log(argc.description());
            self.dy_addReceiveMessageNode(argc);
            },
            });

defineClass('BaseMsgContentViewController', {
            dy_addMessageNode_layout_addMoreMsg: function(arg1,arg2,arg3) {
            self.dy_addMessageNode_layout_addMoreMsg(arg1,arg2,arg3);
            if (arg1.m_uiMessageType()!= 49)
            {
            return;
            }
            
            
            
            },
            });
//onDeleteMessage
            

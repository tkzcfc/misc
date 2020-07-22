/*
* @Author: fangcheng
* @Date:   2020-04-22 14:43:58
* @Last Modified by:   fangcheng
* 事件派发
*/


var EventEmitter = Class.extend({

	// 最大优先级
	PRIORITY_LEVEL_MAX 		: 5,
	// 默认优先级 (越小越先派发)
	PRIORITY_LEVEL_DEFAULT 	: 3,

  	ctor: function(){
  		this.event_listenerMap = {};
  		this.doEmit_Map = {};

  		// 开启调试模式
  		this.DEBUG = true;
  	},


  	/******************************************************* public *******************************************************/

  	/*
	 * 订阅事件
	 * @param event 事件key
	 * @param handler 监听者
	 * @param context handler中的this对象
	 * @param priority 派发优先级 默认3 (越小越先派发)
  	*/
  	on : function(event, handler, context, priority){
  		this.addListener(event, handler, context, -1, priority);
  	},

  	/*
	 * 订阅一次事件
	 * @param event 事件key
	 * @param handler 监听者
	 * @param context handler中的this对象
	 * @param priority 派发优先级 默认3 (越小越先派发)
  	*/
  	once : function(event, handler, context, priority){
  		this.addListener(event, handler, context, 1, priority);  		
  	},

  	/*
	 * 订阅事件
	 * @param event 事件key
	 * @param handler 监听者
	 * @param context handler中的this对象
	 * @param count 订阅次数
	 * @param priority 派发优先级 默认3 (越小越先派发)
  	*/
  	addListener : function(event, handler, context, count, priority){
  		priority = priority || this.PRIORITY_LEVEL_DEFAULT;

  		if(priority < 0 || priority >= this.PRIORITY_LEVEL_MAX){
  			throw new Error("Illegal 'priority'!");
  			return;
  		}

  		if(count === undefined || count === null){
  			throw new Error("Illegal 'count'!");
  			return;
  		}

  		// debug模式下检测重复订阅情况
  		if(this.DEBUG && this.listenerContain(event, handler, context)){
  			// 发生重复订阅情况
			throw new Error("Repeat subscription!");
			return
  		}

  		var listenerTabArr = this.event_listenerMap[event];
  		
  		if(!listenerTabArr){
  			listenerTabArr = [];
  			for(let i = 0; i < this.PRIORITY_LEVEL_MAX; ++i){
  				listenerTabArr[i] = [];
  			}
  			this.event_listenerMap[event] = listenerTabArr;
  		}

  		var listenerTab = listenerTabArr[priority];
  		listenerTab.push({
  			handler : handler,
  			context : context,
  			count : count
  		});
  	},

  	/*
	 * 取消订阅事件
	 * @param event 事件key
	 * @param handler 监听者
	 * @param context handler中的this对象
  	*/
  	removeListener : function(event, handler, context) {
  		var listenerTabArr = this.event_listenerMap[event];

  		if(!listenerTabArr){
  			return;
  		}

  		for(let i = 0; i < listenerTabArr.length; ++i){
  			var listenerTab = listenerTabArr[i];
  			for(let j = 0; j < listenerTab.length; ++j){
  				if(listenerTab[j].handler == handler && listenerTab[j].context == context){
  					listenerTab[j].count = 0;
  				}
  			}
  		}

		if(!this.doEmit_Map[event]){
			this._removeOnce(listenerTabArr);
		}
  		this.clearInvalid();
  	},

	/*
	 * 通过 context 取消订阅所有相关的事件
	 * @param context
  	*/
  	removeAllListenerByContext : function(context) {
  		for(event in this.event_listenerMap){
  			var listenerTabArr = this.event_listenerMap[event];
	
  			if(!listenerTabArr){
  				continue;
  			}
	
  			for(let i = 0; i < listenerTabArr.length; ++i){
  				var listenerTab = listenerTabArr[i];
  				for(let j = 0; j < listenerTab.length; ++j){
  					if(listenerTab[j].context == context){
  						listenerTab[j].count = 0;
  					}
  				}
  			}
	
			if(!this.doEmit_Map[event]){
				this._removeOnce(listenerTabArr);
			}
		}
  		this.clearInvalid();
  	},

	/*
	 * 通过 context 取消某个事件的所有订阅
	 * @param event 事件key
  	*/
  	removeAllListeners: function(event){
		var listenerTabArr = this.event_listenerMap[event];

  		if(!listenerTabArr){
  			return;
  		}

  		if(!this.doEmit_Map[event]){
  			delete this.event_listenerMap[event];
  			delete this.doEmit_Map[event];
  		}
  		else{
  			for(let i = 0; i < listenerTabArr.length; ++i){
  				var listenerTab = listenerTabArr[i];
  				for(let j = 0; j < listenerTab.length; ++j){
  					if(listenerTab[j].context == context){
  						listenerTab[j].count = 0;
  					}
  				}
  			}
  		}
  	},

	/*
	 * 通过 context 查询某个事件的订阅数量
	 * @param event 事件key
  	*/
  	listeners : function(event){
  		var listenerTabArr = this.event_listenerMap[event];

  		if(!listenerTabArr){
  			return 0;
  		}

  		var count = 0;

  		for(let i = 0; i < listenerTabArr.length; ++i){
  			count += listenerTabArr[i].length;
  		}

  		return count;
  	},

  	/*
	 * 查询监听是否已经订阅
	 * @param event 事件key
	 * @param handler 监听者
	 * @param context handler中的this对象
  	*/
  	listenerContain : function(event, handler, context){
  		var listenerTabArr = this.event_listenerMap[event];

  		if(!listenerTabArr){
  			return false;
  		}

  		for(let i = 0; i < listenerTabArr.length; ++i){
  			var listenerTab = listenerTabArr[i];
  			for(let j = 0; j < listenerTab.length; ++j){
  				if(listenerTab[j].handler == handler && listenerTab[j].context == context){
  					return true;
  				}
  			}
  		}

  		return false;
  	},


  	/*
	 * 派发事件
	 * @param event 事件key
	 * @param ...
  	*/
  	emit : function(event, arg0, arg1, arg2, arg3, arg4){
  		if(!event){
  			throw new Error("Illegal 'event'!");
  			return;
  		}

  		var listenerTabArr = this.event_listenerMap[event];
  		if(!listenerTabArr){
  			return 0;
  		}

  		var callCount = 0;
  		var abort = false;

  		this.doEmit_Map[event] = true;

  		for(let i = 0; i < listenerTabArr.length; ++i){
  			var listenerTab = listenerTabArr[i];
  			for(let j = 0; j < listenerTab.length; ++j){
  				listener = listenerTab[j];
  				if(listener.count != 0){

  					if(listener.count > 0){
  						listener.count--;
  					}
  					callCount++;

  					// 派发事件
  					switch(arguments.length){
  						case 1: abort = listener.handler.call(listener.context); break;
  						case 2: abort = listener.handler.call(listener.context, arg0); break;
  						case 3: abort = listener.handler.call(listener.context, arg0, arg1); break;
  						case 4: abort = listener.handler.call(listener.context, arg0, arg1, arg2); break;
  						case 5: abort = listener.handler.call(listener.context, arg0, arg1, arg2, arg3); break;
  						case 6: abort = listener.handler.call(listener.context, arg0, arg1, arg2, arg3, arg4); break;
  						default:{
  							let args = [];
  							for(let k = 1; k < arguments.length; ++k){
  								args[k - 1] = arguments[k];
  							}
  							abort = listener.handler.apply(listener.context, args);
  						}
  					};

  					// 派发中断
  					if(abort === true){
  						break;
  					}
  				}
  			}

			// 派发中断
  			if(abort === true){
  				break;
  			}
  		}

  		this.doEmit_Map[event] = false;

  		this._removeOnce(listenerTabArr);
  		this.clearInvalid();

  		return callCount;
  	},

	/*
	 * 清理
  	*/
  	clear : function(){
  		this.event_listenerMap = {};
  		this.doEmit_Map = {};
  	},

  	/******************************************************* private *******************************************************/

	/*
	 * 清理无效事件
  	*/
  	clearInvalid : function(){
  		// random 1 - 100
  		if(Math.floor((Math.random()*100)+1) == 1){
  			// this.dump();
  			this._clearInvalid();
  			// this.dump();
  		}
  	},

  	_clearInvalid: function(){
  		var runLoop = false;
  		do{
  			runLoop = false;
  			for(event in this.event_listenerMap){
  				if(this.listeners(event) <= 0){
  					delete this.event_listenerMap[event];
  					delete this.doEmit_Map[event];
  					runLoop = true;
  					break;
  				}
  			}
  		}while(runLoop);
  	},

  	/*
	 * 移除无效事件监听
  	*/
  	_removeOnce : function(listenerTabArr){
  		var continueLoop = true;
		for(let i = 0; i < listenerTabArr.length; ++i){
  			var listenerTab = listenerTabArr[i];
  			do{
  				continueLoop = false;
  				for(let j = 0; j < listenerTab.length; ++j){
  					listener = listenerTab[j];
  					if(listener.count == 0){
  						listenerTab.splice(j, 1);
  						continueLoop = true;
  						break;
  					}
  				}
  			}while(continueLoop);
  		}
  	},

  	dump : function(){
  		console.log("dump begin--------------------------------");
  		for(event in this.event_listenerMap){
  			var listenerTabArr = this.event_listenerMap[event];
		
  			for(let i = 0; i < listenerTabArr.length; ++i){
  				var listenerTab = listenerTabArr[i];
  				console.log("dump event:" + event, "priority:" + i, "count:" + listenerTab.length);
  			}
		}
  		console.log("dump end--------------------------------");
  	}
});


var G_NetEventEmitter = new EventEmitter();
var G_SysEventEmitter = new EventEmitter();


/*
///////////////////// Example /////////////////////

var emitter = new EventEmitter();

var Obj = Class.extend({
	initEvent : function(name){
		this.name = name;

		emitter.on("event", function(){
			console.log(this.name, arguments)
		}, this);
	
	
		emitter.on("event1", function(data, count){
			console.log(this.name, data, count)
		}, this);
	},

	destroy : function(){
		emitter.removeAllListenerByContext(this);
	}
});


var o1 = new Obj();
var o2 = new Obj();

o1.initEvent("object1111111");
o1.initEvent("object2222222");

emitter.emit("event", "arg1", "arg2", 3, 4.0, {name:"test"})
emitter.emit("event1", "event1 arg", 10)

o1.destroy();
o2.destroy();

console.log("destroy--------------->>");

emitter.emit("event", "arg1", "arg2", 3, 4.0, {name:"test"})
emitter.emit("event1", "event1 arg")

*/

/*
* @Author: fangcheng
* @Date:   2020-04-03 10:49:20
* @Last Modified by:   fangcheng
* @Last Modified time: 2020-05-20 18:03:06
*/
// "use strict";
var print = console.log

var Event = 
{
	emit : function()
	{
		this.call.apply(this.self, arguments)
	},
	add : function(call, self)
	{
		this.call = call
		this.self = self
		print(this)
	}
};


Event.add(function(arg1, arg2, arg3)
{
	print(this)
	print(arg1, arg2, arg3)
});

Event.emit(1, 20, 30)


// 闭包
var myFunction1 = (function myFunction() {
	var a = 0;
	return (function()
	{
		a += 1;
		return a;
	})
})()

print("myFunction1", myFunction1());
print("myFunction1", myFunction1());

// 
function Person(name, age)
{
	this.name = name;
	this.age = age;
	this.changeName = function(newName)
	{
		this.name = newName;
	};
}


print("class------------------------------------begin");
// 此处无法给对象person添加属性nationality
Person.nationality = "English";

var person = new Person("Sally", 20);
print(person.name);
person.changeName("Doe");
print(person.name);
print(person.nationality);
print("class------------------------------------begin");

// prototype
print("prototype------------------------------------begin");

// 增加一个属性
Person.prototype.nationality = "English";
// 增加一个新方法
Person.prototype.newFunction = function() {
    print('此方法是通过prototype继承后实现的');
};

var person = new Person("Sally", 20);
print(person.name);
person.changeName("Doe");
print(person.name);
print(person.nationality);
print("prototype------------------------------------end");



function MyClass()
{
}

MyClass.prototype.ctor = function(call, tartget)
{
  this.name = "Sender Class";
  this.callFunc = call
  this.callTarget = tartget
}

MyClass.prototype.call = function()
{
  this.callFunc.call(this.callTarget, this);
}

function TestEvent()
{}

TestEvent.prototype.ctor = function()
{
  this.name = "This Class";
  this.cls = new MyClass();
  this.cls.ctor(function(sender, arg1)
    {
      print("this = ", this.name)
      print("sender = " + sender)
      print("arg1 = " + arg1.name)
    }.bind(this, 100), this)
}

var event = new TestEvent();
event.ctor();
event.cls.call();



/*
var GetSetTest = function(){
	this._name = "";
};

GetSetTest.prototype.setName = function(name){
	print("call setName");
	this._name = name;
}

GetSetTest.prototype.getName = function(){
	return this._name;
}

var defineGetterSetter = function (proto, prop, getter, setter){
    var desc = { enumerable: false, configurable: true };
    getter && (desc.get = getter);
    setter && (desc.set = setter);
    Object.defineProperty(proto, prop, desc);
};

defineGetterSetter(GetSetTest.prototype, "nameValue", GetSetTest.prototype.getName, GetSetTest.prototype.setName);

var gst = new GetSetTest();
gst.nameValue = "haha";
print(gst.nameValue);
*/


















// print(lastPlayEndTimeMng[ev1]);
// print(ev1.toString())

// /* Simple JavaScript Inheritance
//  * By John Resig https://johnresig.com/
//  * MIT Licensed.
//  */
// // Inspired by base2 and Prototype
// (function(){
//   var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;
 
//   // The base Class implementation (does nothing)
//   this.Class = function(){};
   
//   // Create a new Class that inherits from this class
//   Class.extend = function(prop) {
//     var _super = this.prototype;
     
//     // Instantiate a base class (but only create the instance,
//     // don't run the init constructor)
//     initializing = true;
//     var prototype = new this();
//     initializing = false;
     
//     // Copy the properties over onto the new prototype
//     for (var name in prop) {
//       // Check if we're overwriting an existing function
//       prototype[name] = typeof prop[name] == "function" && 
//         typeof _super[name] == "function" && fnTest.test(prop[name]) ?
//         (function(name, fn){
//           return function() {
//             var tmp = this._super;
             
//             // Add a new ._super() method that is the same method
//             // but on the super-class
//             this._super = _super[name];
             
//             // The method only need to be bound temporarily, so we
//             // remove it when we're done executing
//             var ret = fn.apply(this, arguments);        
//             this._super = tmp;
             
//             return ret;
//           };
//         })(name, prop[name]) :
//         prop[name];
//     }
     
//     // The dummy class constructor
//     function Class() {
//       // All construction is actually done in the init method
//       if ( !initializing && this.init )
//         this.init.apply(this, arguments);
//     }
     
//     // Populate our constructed prototype object
//     Class.prototype = prototype;
     
//     // Enforce the constructor to be what we expect
//     Class.prototype.constructor = Class;
 
//     // And make this class extendable
//     Class.extend = arguments.callee;
     
//     return Class;
//   };
// })();

// var Person = Class.extend({
//   init: function(isDancing){
//   	print("init--------->>",isDancing)
//     this.dancing = isDancing;
//   },
//   dance: function(){
//     return this.dancing;
//   }
// });
 
// var Ninja = Person.extend({
//   init: function(){
//     this._super( false );
//   },
//   dance: function(){
//     // Call the inherited version of dance()
//     return this._super();
//   },
//   swingSword: function(){
//     return true;
//   }
// });
 
// var p = new Person(true);
// p.dance(); // => true
 
// var n = new Ninja();
// n.dance(); // => false
// n.swingSword(); // => true
 
// // Should all be true
// print(p instanceof Person && p instanceof Class && p instanceof Object &&
// n instanceof Ninja && n instanceof Person && n instanceof Class)

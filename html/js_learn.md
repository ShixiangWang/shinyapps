# Javascript 学习笔记

## 第一步

打开谷歌浏览器，按下 `Option + Command + J`（Mac）或者 `Ctrl + Shift + J`（Windows / Linux）进入控制台。

`Enter` 运行代码；`Shift + Enter` 换行。

## js 基本语法

```js
var a = 1;
var b;
b = "abc";

// 合法标志符
arg0
_tmp
$elem

// 注释
// 行注释
/*
块注释
*/

// 代码块
{

}

//  if
if (a == 1) {
  console.log("a == 1");
} else {
  console.log("a != 1");
}

// switch
switch (a) {
  case 1:
    // ...
    break;
  case 2:
    // ...
    break;
  default:
    // ...
}

// 三元运算符
var even = (n % 2 === 0) ? true : false;

// 循环
while (a > 0) {
  // ...
}

var x = 3;
for (var i = 0; i < x; i++) {
  console.log(i)
}

do
  // ...
while (true);

// break and continue

// label
foo: {
  console.log(1);
  break foo;
  console.log(2);
}
console.log(3)
```

## 数据类型

### 简介

- 数值 number
- 字符串 string
- 布尔值 boolean
- 未定义 undefined
- 空值 null
- 对象 object（值的集合）

前三者合称为原始类型，不能再细分。对象成为合成类型，是基于原始类型构建的。未定义与空值一般看作两个特殊值。

对象一般可以分为 3 个子类型：

- 狭义的对象
- 数组
- 函数

JS 有 3 种方法确定值的类型：

- `typeof` - 运算符
- `instanceof` - 运算符
- `Object.prototype.toString` - 方法

```js
> typeof 123
'number'
> typeof "123"
'string'
> typeof false
'boolean'
> typeof function f() {}
'function'
> typeof undefined
'undefined'
> typeof v
'undefined'
> typeof null // 历史原因造成的
'object'
> typeof {}
'object'
> typeof []
'object'

> var o = {}
undefined
> var a = []
undefined
> o instanceof Array
false
> a instanceof Array
true
```


null, undefined 和布尔值 详解：<https://wangdoc.com/javascript/types/null-undefined-boolean.html>.

### 数值

转换和测试方法。

```js
parseInt()
parseFloat()
isNaN()
isFinite()
```

### 字符串

单双引号等同。

> 由于 HTML 语言的属性值使用双引号，所以很多项目约定 JavaScript 语言的字符串只使用单引号，本教程遵守这个约定。当然，只使用双引号也完全可以。重要的是坚持使用一种风格，不要一会使用单引号表示字符串，一会又使用双引号表示。

连接运算符（+）可以连接多个单行字符串。

字符串可以被视为字符数组，因此可以使用数组的方括号运算符，用来返回某个位置的字符（位置编号从0开始）。

如果方括号中的数字超过字符串的长度，或者方括号中根本不是数字，则返回 undefined。

```js
> var s = 'hello';
undefined
> s[0]
'h'
> s[1]
'e'
> 
> s[-1]
undefined
> s.length
5
> '𝌆'.length
2
```

上面代码中，JavaScript 认为𝌆的长度为 2，而不是 1。

Base64 就是一种编码方法，可以将任意值转成 0～9、A～Z、a-z、+和/这64个字符组成的可打印字符。使用它的主要目的，不是为了加密，而是为了不出现特殊字符，简化程序的处理。

JavaScript 原生提供两个 Base64 相关的方法。

- `btoa()`：任意值转为 Base64 编码
- `atob()`：Base64 编码转为原来的值

```js
// 无法在 node 中直接使用
var string = 'Hello World!';
btoa(string) // "SGVsbG8gV29ybGQh"
atob('SGVsbG8gV29ybGQh') // "Hello World!"
```

### 对象

js 中对象就是一组“键值对”（key-value）的集合，是一种无序的复合数据集合。

在其他编程语言中，这种对象概念常被称为字典。

对象的所有键名都是字符串（ES6 又引入了 Symbol 值也可以作为键名），所以加不加引号都可以。

```js
> var obj1 = {a:1, b:2}
undefined
> obj1
{ a: 1, b: 2 }
> var obj2 = {'a':1, 'b':2}
undefined
> obj2
{ a: 1, b: 2 }
```

**对象的每一个键名又称为“属性”（property），它的“键值”可以是任何数据类型。如果一个属性的值为函数，通常把这个属性称为“方法”，它可以像函数那样调用。**

```js
> var obj = {
... printHello: function(x) {
..... console.log("Hello" + x)
..... }
... }
undefined
> obj.printHello('world')
Helloworld
```

如果不同的变量名指向同一个对象，那么它们都是这个对象的引用，也就是说指向同一个内存地址。修改其中一个变量，会影响到其他所有变量。

但是，这种引用只局限于对象，如果两个变量指向同一个原始类型的值。那么，变量这时都是值的拷贝。

读取对象的属性，有两种方法，一种是使用点运算符，还有一种是使用方括号运算符。

```js
> obj1.a
1
> obj1['a']
1
```

查看属性：

```js
> Object.keys(obj1)
[ 'a', 'b' ]
```

删除：

```js
> delete obj1.a
true
> obj1
{ b: 2 }
```

注意，删除一个不存在的属性，delete 不报错，而且返回 true。

用 `in` 运算符判断属性存在：

```js
> 'a' in obj1
false
> 'b' in obj1
true
```

`in` 运算符的一个问题是，它不能识别哪些属性是对象自身的，哪些属性是继承的。
这时候可以使用 `hasOwnProperty` 方法。

```js
> 'toString' in obj1
true
> obj1.hasOwnProperty('toString')
false
```

`for...in` 循环用来遍历一个对象的全部属性。

```js
> var obj = {a: 1, b:2, c:3};
undefined
> for (var i in obj) {
... console.log('key: ', i);
... console.log('value: ', obj[i]);
... }
key:  a
value:  1
key:  b
value:  2
key:  c
value:  3
```

它遍历的是对象所有可遍历（enumerable）的属性（包括继承的），会跳过不可遍历的属性。

`with` 语句提供了修改对象的方便操作，类似于 R 中的 `with`。

```js
var obj = {
  p1: 1,
  p2: 2,
};
with (obj) {
  p1 = 4;
  p2 = 5;
}
// 等同于
obj.p1 = 4;
obj.p2 = 5;
```

## electron 使用

### 创建项目文件夹并安装 electron

```
mkdir my-electron-app && cd my-electron-app
npm init -y
npm i --save-dev electron
```

- <https://www.limitcode.com/detail/59a15b1a69e95702e0780249.html>
- <https://learnku.com/articles/15975/npm-accelerate-and-modify-mirror-source-in-china>

配置淘宝镜像：

```
npm config set registry https://registry.npm.taobao.org
npm config set disturl https://npm.taobao.org/dist
npm config set electron_mirror https://npm.taobao.org/mirrors/electron/
```

### 应用打包和分发

```
# 应用 Electron forge
npx @electron-forge/cli import
# 创建分发版本，结果在 out 目录下
npm run make
```

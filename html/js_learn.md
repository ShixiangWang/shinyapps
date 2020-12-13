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

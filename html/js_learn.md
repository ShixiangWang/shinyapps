# Javascript 学习笔记

## 第一步

打开谷歌浏览器，按下 `Option + Command + J`（Mac）或者 `Ctrl + Shift + J`（Windows / Linux）进入控制台。

`Enter` 运行代码；`Shift + Enter` 换行。

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

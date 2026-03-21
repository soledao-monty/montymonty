# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an OpenHarmony/HarmonyOS application (montymonty) with the following characteristics:
- **Bundle name**: com.example.montymonty
- **Language**: ETS (Extended TypeScript)
- **Target device**: Phone
- **SDK version**: 6.0.2 (API 22)

## Common Commands

### Build
```bash
hvigorw build
```
Build the debug variant (default).

### Build Release
```bash
hvigorw build --release
```

### Clean Build
```bash
hvigorw clean
```

### Run Tests
Tests use the Hypium testing framework. Unit tests are located in `entry/src/test/`.

```bash
hvigorw test
```

### Lint
Code linting is configured via `code-linter.json5`. Lint runs automatically during build. To manually lint:
```bash
hvigorw lint
```

## 项目架构

### 目录结构
```
entry/src/main/
├── ets/
│   ├── entryability/EntryAbility.ets      # 应用入口
│   ├── entrybackupability/                # 备份扩展
│   ├── model/
│   │   └── MemoryCard.ts                  # 数据模型
│   ├── pages/
│   │   ├── HomePage.ets                   # 首页（回忆列表）
│   │   ├── CreateMemoryPage.ets           # 创建回忆页面
│   │   └── MemoryDetailPage.ets           # 回忆详情页
│   ├── components/
│   │   ├── MemoryCard.ets                 # 回忆卡片组件
│   │   ├── MediaGrid.ets                  # 照片网格组件
│   │   └── GlassmorphicCard.ets           # 毛玻璃卡片组件
│   ├── services/
│   │   ├── StorageService.ts              # SQLite 存储服务
│   │   ├── MediaService.ts                # 照片/视频选择服务
│   │   └── LocationService.ts             # 位置服务
│   └── utils/
│       ├── uuid.ts                        # UUID 生成器
│       └── dateFormat.ts                  # 日期格式化工具
├── module.json5                           # 模块配置
└── resources/
    └── base/profile/main_pages.json       # 页面路由配置

AppScope/
├── app.json5                             # 应用配置
└── resources/                            # 应用级资源
```

### 核心组件
- **EntryAbility**: 应用主入口，继承 UIAbility，处理生命周期事件（onCreate、onDestroy、onForeground、onBackground）和窗口阶段管理。
- **HomePage**: 首页，展示回忆列表，底部有浮动"记录此刻"按钮。
- **CreateMemoryPage**: 创建回忆页面，支持文字描述（必填）、时间、地点、1-50张照片。
- **MemoryDetailPage**: 回忆详情页，展示照片网格、完整描述、时间地点信息，支持删除。
- **MemoryCard**: 回忆卡片组件，用于列表中展示回忆预览。
- **MediaGrid**: 照片网格布局组件（创建页3列，详情页2列）。
- **GlassmorphicCard**: 毛玻璃背景卡片组件。
- **StorageService**: SQLite 数据库服务，使用 relationalStore。
- **MediaService**: 照片/视频选择服务，使用 PhotoViewPicker。
- **LocationService**: 位置服务，使用 geoLocationManager。
- **MemoryCard**: 回忆记录的数据模型接口。

### 功能特性
- **创建回忆**: 记录此刻，包含文字描述（必填）、时间、地点、1-50张照片
- **浏览回忆**: 按时间倒序展示所有回忆
- **查看详情**: 查看回忆完整内容和所有照片
- **删除回忆**: 从详情页删除回忆

### 数据库
- **类型**: SQLite (relationalStore)
- **数据库名**: MemoryFlow.db
- **表名**: memory_cards

### 配置说明
- `module.json5`: 定义 ability、扩展 ability、页面和设备类型
- `app.json5`: 应用级配置（包名、版本、图标）
- `build-profile.json5`: 构建配置，包含签名配置
- `code-linter.json5`: 代码检查规则（针对 ETS 文件，排除 test/mock 目录）

### TODO (V1.1 已完成)
1. ✅ 创建回忆的时候，当前时间不允许修改 - 已添加 DatePicker 和 TimePicker
2. ✅ 选择照片后删除按钮无法取消 - 已修复，增大点击区域
3. ✅ 选择视频后预览黑色 - 已修复，使用 Video 组件显示视频
4. ✅ 已保存的回忆支持编辑功能 - 已创建 EditMemoryPage，同步更新 PRD 为 V1.1
5. ✅ 回忆列表地点左边加小图标 - 已添加 📍 图标
6. ✅ 应用布局扩展到上下安全区 - 已使用 padding 和 layoutSafeArea 优化
7. ✅ 查看回忆详情时大图预览 - 已实现 Swiper 左右滑动预览
8. ✅ 删除回忆增加二次确认弹窗 - 已添加 AlertDialog

## ArkTS/ArkUI 编码规范

### 1. 组件属性必须使用链式调用
ArkUI 组件的样式属性（如 `objectFit`、`borderRadius`、`width`、`height` 等）**必须在构造函数后使用链式方法调用**，不能在构造函数参数中传递。

```typescript
// ❌ 错误
Video({
  src: uri,
  objectFit: ImageFit.Cover  // 构造函数中不能传 objectFit
})

// ✅ 正确
Video({
  src: uri
})
  .objectFit(ImageFit.Cover)
  .width('100%')
  .height(300)
```

### 2. 弹窗组件不能在条件渲染中使用
`DatePickerDialog`、`TimePickerDialog` 等弹窗组件**不能**在 `@Component` 的 `build()` 方法中通过 `if` 条件渲染使用。必须在点击事件处理函数中直接调用 `.show()` 方法。

```typescript
// ❌ 错误
if (this.showDatePicker) {
  DatePickerDialog.show({ ... })
}

// ✅ 正确：点击时直接调用
Text('修改').onClick(() => {
  DatePickerDialog.show({ ... })
})
```

### 3. 不使用事件冒泡阻止
ArkUI 的 `ClickEvent` **没有** `stopPropagation()` 方法，不需要手动阻止事件冒泡。

```typescript
// ❌ 错误
.onClick((event: ClickEvent) => {
  event.stopPropagation(); // 不存在
})

// ✅ 正确：直接处理点击
.onClick(() => {
  this.onItemRemove(index);
})
```

### 4. 严格进行空值检查
使用 `@State` 声明的可为 null 的对象时，必须先进行空值检查再访问其属性。

```typescript
// ❌ 错误
if (!this.isVideo(this.memory.mediaUris[0])) { // this.memory 可能为 null

// ✅ 正确
if (this.memory && !this.isVideo(this.memory.mediaUris[0])) {
```

### 5. 正确导入模块成员
只导入实际使用的成员，部分成员可能不存在于模块中。

```typescript
// ❌ 错误
import { router, promptAction, dialog } from '@kit.ArkUI'; // dialog 不存在

// ✅ 正确
import { router, promptAction } from '@kit.ArkUI';
// AlertDialog 是内置组件，直接使用即可
```

### 6. 安全区扩展使用 expandSafeArea
扩展安全区域应使用 `expandSafeArea()` 方法，而不是固定的 padding 或 `layoutSafeArea()`。

```typescript
// ❌ 错误：使用固定 padding
Column().padding({ top: 48, bottom: 34 })

// ❌ 错误：layoutSafeArea 不是所有组件都支持
Stack().layoutSafeArea(true)

// ✅ 正确：使用 expandSafeArea 扩展到系统安全区域
Column()
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
```

`SafeAreaType.SYSTEM` 表示系统安全区域，`SafeAreaEdge.TOP` 和 `SafeAreaEdge.BOTTOM` 分别表示顶部和底部。

### 7. 每个页面都需要做成沉浸式布局
所有页面（HomePage、CreateMemoryPage、MemoryDetailPage、EditMemoryPage 等）都必须使用沉浸式布局，确保内容扩展到状态栏和导航栏区域。

```typescript
// ✅ 正确：在根容器上使用 expandSafeArea
Column() {
  // 页面内容
}
  .width('100%')
  .height('100%')
  .backgroundColor('#1a1a2e')
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
```

**重要**：新增页面时也必须遵循此规范，不能使用固定的 padding 来处理安全区。

### 8. Video 组件特殊注意
`Video` 组件的构造函数只接受 `src` 属性，样式属性必须通过链式调用设置。

```typescript
// ❌ 错误
Video({
  src: uri,
  previewUri: uri,  // 不存在的属性
  objectFit: ImageFit.Cover  // 构造函数中不能传
})

// ✅ 正确
Video({
  src: uri
})
  .objectFit(ImageFit.Cover)
  .autoPlay(true)
  .controls(true)
```

### 9. 不使用 ArkUI 保留字段作为组件属性名
ArkUI 的内置属性（如 `width`、`height`、`borderRadius`、`id`、`tag`、`opacity` 等）**不能**作为自定义组件的 `@Prop` 或 `@State` 变量名，否则会与基类属性冲突导致编译错误。

```typescript
// ❌ 错误
@Prop width: string = '100%';  // 与基类 Component 的 width 冲突
@Prop height: number = 100;
@Prop borderRadius: number = 0;

// ✅ 正确
@Prop imgWidth: string = '100%';
@Prop imgHeight: number = 100;
@Prop radius: number = 0;
```

### 10. 使用 interface 定义对象类型
ArkTS 不支持使用对象字面量作为类型声明，必须使用 `interface` 定义类型。

```typescript
// ❌ 错误
function getBounds(): { x: number, y: number, width: number, height: number } {
  return { x: 0, y: 0, width: 100, height: 100 };
}

// ✅ 正确
interface RectBounds {
  x: number;
  y: number;
  width: number;
  height: number;
}

function getBounds(): RectBounds {
  return { x: 0, y: 0, width: 100, height: 100 };
}
```
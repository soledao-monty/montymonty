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

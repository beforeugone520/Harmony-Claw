# Harmony Claw

OpenClaw Gateway Manager for HarmonyOS - 一个用于管理网关、会话、消息和进程的 HarmonyOS ArkTS 应用程序。

## 项目概述

Harmony Claw 是一个基于 HarmonyOS API 12 开发的企业级网关管理应用，提供了对 OpenClaw 网关系统的完整管理能力。

## 当前进度

- **整体进度**: 55%
- **Phase 1 (规划与基础)**: ✅ 100% 完成
- **Phase 2 (核心开发)**: 🟡 71% 完成
- **Phase 3 (测试与优化)**: ⏳ 等待中
- **Phase 4 (发布准备)**: ⏳ 等待中

## 已实现功能

### ✅ 基础架构
- [x] 项目结构和配置
- [x] 设计系统 (DesignTokens, Spacing, Animation)
- [x] API 端点常量
- [x] 工具类 (DateUtils, NetworkUtils)

### ✅ 数据模型
- [x] Gateway 实体类
- [x] Session 实体类
- [x] Message 实体类
- [x] Process 实体类
- [x] LogEntry 实体类

### ✅ Services 层
- [x] HttpService - HTTP 客户端
- [x] StorageService - 本地存储
- [x] GatewayDiscoveryService - 网关发现

### ✅ Repository 层
- [x] GatewayRepository - 网关管理
- [x] ChatRepository - 会话和消息
- [x] ProcessRepository - 进程管理

### ✅ ViewModel 层
- [x] GatewayViewModel
- [x] ChatViewModel
- [x] ProcessViewModel

### ✅ UI 组件
- [x] GatewayCard, GatewayStatusBadge
- [x] MessageBubble, ChatInput, SessionItem
- [x] ProcessCard, ProcessStatusIcon
- [x] LoadingState, EmptyState, ErrorState, StatusBadge

### ✅ 页面
- [x] Index (主页面，集成 Dashboard)
- [x] GatewayListPage (网关列表)
- [x] ChatPage (对话页面)
- [x] ProcessListPage (进程监控)
- [x] SettingsPage (设置)

## 技术栈

- **平台**: HarmonyOS 6.0+
- **SDK**: API 12 (5.0.0)
- **语言**: ArkTS 3.0+
- **开发模式**: Stage Model
- **架构**: MVVM + Repository 模式

## 项目结构

```
Harmony-Claw/
├── AppScope/                          # 应用级配置
│   ├── app.json5                      # 应用配置
│   └── resources/base/                # 应用级资源
│
├── entry/                             # 入口模块
│   └── src/main/
│       ├── ets/                       # ArkTS 源码
│       │   ├── entryability/          # 入口 Ability
│       │   ├── pages/                 # 页面
│       │   │   ├── Index.ets          # 启动页/Dashboard
│       │   │   ├── GatewayListPage.ets
│       │   │   ├── ChatPage.ets
│       │   │   ├── ProcessListPage.ets
│       │   │   └── SettingsPage.ets
│       │   │
│       │   ├── components/            # 可复用组件
│       │   │   ├── gateway/
│       │   │   ├── chat/
│       │   │   ├── process/
│       │   │   └── common/
│       │   │
│       │   ├── models/                # 数据模型
│       │   ├── repositories/          # 数据仓库
│       │   ├── services/              # 服务层
│       │   ├── viewmodels/            # 视图模型
│       │   ├── constants/             # 常量
│       │   ├── styles/                # 样式系统
│       │   └── utils/                 # 工具类
│       │
│       └── resources/                 # 模块资源
│
├── build-profile.json5                # 构建配置
├── hvigorfile.ts
└── oh-package.json5                   # 项目配置
```

## 核心功能

### 网关管理
- 自动发现局域网内的 OpenClaw 网关
- 手动添加网关（IP:端口）
- 网关状态监控（在线/离线/错误）
- 网关连接和切换

### 对话中心
- 创建和管理会话
- 发送和接收消息
- 用户/AI 消息气泡样式
- 消息历史记录

### 进程监控
- 查看运行中的进程
- 显示 CPU 和内存占用
- 终止进程操作
- 实时刷新

### 设置
- 主题切换
- 通知设置
- 自动刷新设置
- 清除缓存

## 开发环境要求

- HarmonyOS SDK API 12
- DevEco Studio 4.0+
- Node.js 16+

## 构建和运行

```bash
# 在 DevEco Studio 中:
# 1. 打开项目
# 2. 同步项目 (Sync Project)
# 3. 构建 (Build → Build Hap)
# 4. 运行 (Run → Run 'entry')
```

## API 集成

应用通过 `OpenClawAPI.ets` 中定义的 DTO 与后端 API 交互，支持：
- RESTful API 调用 (GET/POST/DELETE)
- 数据持久化 (Preferences)
- 网关自动发现
- 错误处理和重试机制

## 下一步计划

1. **完善功能**
   - 添加更多页面跳转
   - 完善页面转场动画
   - 添加图标资源

2. **测试阶段**
   - 编写单元测试
   - 集成测试
   - UI 测试

3. **发布准备**
   - 应用图标设计
   - 文档完善
   - 打包签名

## 许可证

MIT License

# OpenClaw Gateway Manager - 任务清单

> **项目**: OpenClaw 网关管理应用  
> **版本**: v1.0  
> **最后更新**: 2026-03-09

---

## 📋 任务说明

- **优先级**: P0(必须) / P1(应该) / P2(可以)
- **依赖**: `->` 表示依赖前置任务
- **状态**: `- [ ]` 未完成 / `- [x]` 已完成

---

## Phase 1: 规划与基础 (Week 1-2)

### 1.1 项目初始化

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 HarmonyOS 项目结构 | P0 | - | `/` | `DevEco Studio → Create Project` |
| - [ ] | 配置项目 build-profile.json5 | P0 | 项目创建 | `build-profile.json5` | 设置 `compileSdkVersion: 12` |
| - [ ] | 配置 oh-package.json5 依赖 | P0 | 项目创建 | `oh-package.json5` | 添加必要依赖 |
| - [ ] | 创建 AppScope 应用配置 | P0 | 项目创建 | `AppScope/resources/base/` | 配置应用图标、名称 |
| - [ ] | 配置模块 module.json5 | P0 | 项目创建 | `entry/src/main/module.json5` | 声明权限、Ability |

### 1.2 基础架构搭建

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建常量定义文件 - DesignTokens | P0 | 项目初始化 | `constants/DesignTokens.ets` | 定义品牌色、功能色 |
| - [ ] | 创建常量定义文件 - Spacing | P0 | 项目初始化 | `constants/Spacing.ets` | 定义间距系统 |
| - [ ] | 创建常量定义文件 - Animation | P0 | 项目初始化 | `constants/Animation.ets` | 定义动画时长、曲线 |
| - [ ] | 创建常量定义文件 - ApiEndpoints | P0 | 项目初始化 | `constants/ApiEndpoints.ets` | 定义 API 端点常量 |
| - [ ] | 创建工具类 - DateUtils | P1 | 项目初始化 | `utils/DateUtils.ets` | 时间格式化函数 |
| - [ ] | 创建工具类 - NetworkUtils | P1 | 项目初始化 | `utils/NetworkUtils.ets` | IP/端口验证函数 |

### 1.3 数据模型定义

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 定义 Gateway 实体类 | P0 | 基础架构 | `models/Gateway.ets` | `class Gateway { id, name, host, port }` |
| - [ ] | 定义 Session 实体类 | P0 | 基础架构 | `models/Session.ets` | `class Session { id, title, createdAt }` |
| - [ ] | 定义 Message 实体类 | P0 | 基础架构 | `models/Message.ets` | `enum MessageRole`, `class Message` |
| - [ ] | 定义 Process 实体类 | P0 | 基础架构 | `models/Process.ets` | `enum ProcessStatus`, `class Process` |
| - [ ] | 定义 API DTO 接口 | P0 | 数据实体 | `dto/OpenClawAPI.ets` | `interface ApiResponse<T>` |

---

## Phase 2: 核心开发 (Week 3-8)

### 2.1 网络与存储服务层

#### 2.1.1 HTTP 服务
| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 HttpService 基础类 | P0 | 数据模型 | `services/HttpService.ets` | `import http from '@ohos.net.http'` |
| - [ ] | 实现 GET 请求方法 | P0 | HttpService | `services/HttpService.ets` | `async get<T>(path, params)` |
| - [ ] | 实现 POST 请求方法 | P0 | HttpService | `services/HttpService.ets` | `async post<T>(path, data)` |
| - [ ] | 实现 DELETE 请求方法 | P0 | HttpService | `services/HttpService.ets` | `async delete<T>(path)` |
| - [ ] | 实现连接检测方法 | P0 | HttpService | `services/HttpService.ets` | `async checkConnection(): Promise<boolean>` |
| - [ ] | 实现错误处理拦截器 | P1 | HTTP方法 | `services/HttpService.ets` | `private handleResponse<T>()` |

#### 2.1.2 存储服务
| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 StorageService 类 | P0 | 数据模型 | `services/StorageService.ets` | `import preferences from '@ohos.data.preferences'` |
| - [ ] | 实现网关数据持久化 | P0 | StorageService | `services/StorageService.ets` | `saveGateways()`, `loadGateways()` |
| - [ ] | 实现会话数据缓存 | P1 | StorageService | `services/StorageService.ets` | `saveSessions()`, `loadSessions()` |
| - [ ] | 实现应用配置存储 | P1 | StorageService | `services/StorageService.ets` | `saveSettings()`, `loadSettings()` |

#### 2.1.3 网关发现服务
| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 GatewayDiscoveryService | P0 | HttpService | `services/GatewayDiscoveryService.ets` | `class GatewayDiscoveryService` |
| - [ ] | 实现局域网扫描功能 | P0 | 发现服务 | `services/GatewayDiscoveryService.ets` | 扫描 8333 端口 |
| - [ ] | 实现手动添加验证 | P0 | 发现服务 | `services/GatewayDiscoveryService.ets` | `validateGateway(ip, port)` |
| - [ ] | 实现在线状态检测 | P1 | 发现服务 | `services/GatewayDiscoveryService.ets` | `checkOnlineStatus(gateway)` |

### 2.2 Repository 数据层

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 GatewayRepository | P0 | 存储服务 | `repositories/GatewayRepository.ets` | `class GatewayRepository` |
| - [ ] | 实现网关 CRUD 操作 | P0 | GatewayRepository | `repositories/GatewayRepository.ets` | `getAll()`, `add()`, `update()`, `delete()` |
| - [ ] | 实现当前网关管理 | P0 | GatewayRepository | `repositories/GatewayRepository.ets` | `getCurrent()`, `setCurrent()` |
| - [ ] | 创建 ChatRepository | P0 | HTTP服务 | `repositories/ChatRepository.ets` | `class ChatRepository` |
| - [ ] | 实现会话管理 | P0 | ChatRepository | `repositories/ChatRepository.ets` | `getSessions()`, `createSession()` |
| - [ ] | 实现消息管理 | P0 | ChatRepository | `repositories/ChatRepository.ets` | `getMessages()`, `sendMessage()` |
| - [ ] | 创建 ProcessRepository | P0 | HTTP服务 | `repositories/ProcessRepository.ets` | `class ProcessRepository` |
| - [ ] | 实现进程查询 | P0 | ProcessRepository | `repositories/ProcessRepository.ets` | `getProcesses()`, `getProcessDetail()` |
| - [ ] | 实现进程控制 | P1 | ProcessRepository | `repositories/ProcessRepository.ets` | `terminateProcess(id)` |

### 2.3 ViewModel 层

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 GatewayViewModel | P0 | GatewayRepository | `viewmodels/GatewayViewModel.ets` | `@ObservedV2 class GatewayViewModel` |
| - [ ] | 实现网关扫描状态管理 | P0 | GatewayViewModel | `viewmodels/GatewayViewModel.ets` | `@Trace isScanning`, `@Trace gateways` |
| - [ ] | 实现网关连接逻辑 | P0 | GatewayViewModel | `viewmodels/GatewayViewModel.ets` | `async connectGateway(gateway)` |
| - [ ] | 创建 ChatViewModel | P0 | ChatRepository | `viewmodels/ChatViewModel.ets` | `@ObservedV2 class ChatViewModel` |
| - [ ] | 实现会话列表状态 | P0 | ChatViewModel | `viewmodels/ChatViewModel.ets` | `@Trace sessions`, `loadSessions()` |
| - [ ] | 实现消息发送逻辑 | P0 | ChatViewModel | `viewmodels/ChatViewModel.ets` | `async sendMessage(content)` |
| - [ ] | 实现消息接收处理 | P0 | ChatViewModel | `viewmodels/ChatViewModel.ets` | 处理响应/流式数据 |
| - [ ] | 创建 ProcessViewModel | P0 | ProcessRepository | `viewmodels/ProcessViewModel.ets` | `@ObservedV2 class ProcessViewModel` |
| - [x] | 实现进程列表刷新 | P0 | ProcessViewModel | `viewmodels/ProcessViewModel.ets` | `async loadProcesses()` |
| - [ ] | 实现进程操作 | P1 | ProcessViewModel | `viewmodels/ProcessViewModel.ets` | `async terminateProcess(id)` |

### 2.4 通用组件开发

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 创建 LoadingView 组件 | P0 | DesignTokens | `components/common/LoadingView.ets` | `@Component struct LoadingView` |
| - [ ] | 创建 EmptyView 组件 | P0 | DesignTokens | `components/common/EmptyView.ets` | 空状态展示组件 |
| - [ ] | 创建 ErrorView 组件 | P0 | DesignTokens | `components/common/ErrorView.ets` | 错误状态展示组件 |
| - [ ] | 创建通用按钮组件 | P1 | DesignTokens | `components/common/ActionButton.ets` | 统一风格按钮 |

### 2.5 网关模块 UI

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [x] | 创建 GatewayCard 组件 | P0 | 通用组件 | `components/gateway/GatewayCard.ets` | 网关卡片展示 |
| - [x] | 创建 GatewayStatusBadge 组件 | P0 | DesignTokens | `components/gateway/GatewayStatusBadge.ets` | 在线状态徽章 |
| - [x] | 创建 GatewayListPage 页面 | P0 | GatewayCard | `pages/gateway/GatewayListPage.ets` | 网关列表页 |
| - [x] | 实现网关扫描 UI | P0 | GatewayListPage | `pages/gateway/GatewayListPage.ets` | 扫描动画、结果列表 |
| - [ ] | 创建 AddGatewayPage 页面 | P0 | GatewayListPage | `pages/gateway/AddGatewayPage.ets` | 手动添加表单 |
| - [x] | 实现 IP 端口输入验证 | P0 | AddGatewayPage | `pages/gateway/AddGatewayPage.ets` | 正则验证、连接测试 |
| - [ ] | 创建 GatewayDetailPage 页面 | P1 | GatewayListPage | `pages/gateway/GatewayDetailPage.ets` | 网关详情、编辑 |

### 2.6 对话模块 UI

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [x] | 创建 MessageBubble 组件 | P0 | DesignTokens | `components/chat/MessageBubble.ets` | 消息气泡样式 |
| - [x] | 实现用户消息样式 | P0 | MessageBubble | `components/chat/MessageBubble.ets` | 蓝色右对齐气泡 |
| - [x] | 实现 AI 消息样式 | P0 | MessageBubble | `components/chat/MessageBubble.ets` | 灰色左对齐气泡 |
| - [x] | 创建 MessageList 组件 | P0 | MessageBubble | `components/chat/MessageList.ets` | 消息列表、滚动 |
| - [x] | 创建 ChatInput 组件 | P0 | DesignTokens | `components/chat/ChatInput.ets` | 输入框、发送按钮 |
| - [x] | 实现输入框状态管理 | P0 | ChatInput | `components/chat/ChatInput.ets` | 空输入禁用发送 |
| - [x] | 创建 SessionItem 组件 | P0 | DesignTokens | `components/chat/SessionItem.ets` | 会话列表项 |
| - [ ] | 创建 SessionListPage 页面 | P0 | SessionItem | `pages/chat/SessionListPage.ets` | 会话列表页 |
| - [x] | 创建 ChatPage 页面 | P0 | MessageList | `pages/chat/ChatPage.ets` | 聊天界面 |
| - [x] | 实现消息发送交互 | P0 | ChatPage | `pages/chat/ChatPage.ets` | 发送 loading、失败重试 |
| - [ ] | 实现下拉刷新历史 | P1 | ChatPage | `pages/chat/ChatPage.ets` | `Refresh` 组件 |

### 2.7 进程模块 UI

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [x] | 创建 ProcessCard 组件 | P0 | DesignTokens | `components/process/ProcessCard.ets` | 进程卡片 |
| - [x] | 创建 ProcessStatusIcon 组件 | P0 | DesignTokens | `components/process/ProcessStatusIcon.ets` | 状态图标 |
| - [x] | 创建 ProcessListPage 页面 | P0 | ProcessCard | `pages/process/ProcessListPage.ets` | 进程列表页 |
| - [ ] | 实现进程列表刷新 | P0 | ProcessListPage | `pages/process/ProcessListPage.ets` | 定时刷新、手动刷新 |
| - [x] | 实现进程终止操作 | P1 | ProcessListPage | `pages/process/ProcessListPage.ets` | 确认对话框、终止按钮 |
| - [ ] | 添加进程资源图表 | P1 | ProcessListPage | `pages/process/ProcessListPage.ets` | CPU/内存进度条 |

### 2.8 设置模块 UI

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [x] | 创建 SettingsPage 页面 | P1 | 通用组件 | `pages/settings/SettingsPage.ets` | 设置列表 |
| - [x] | 实现主题切换功能 | P1 | SettingsPage | `pages/settings/SettingsPage.ets` | 深色/浅色/跟随系统 |
| - [x] | 实现缓存清理功能 | P2 | SettingsPage | `pages/settings/SettingsPage.ets` | 清除本地数据 |
| - [ ] | 创建关于页面 | P1 | SettingsPage | `pages/settings/AboutPage.ets` | 版本信息、开源协议 |

### 2.9 主框架与导航

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [x] | 创建 EntryAbility | P0 | 所有模块 | `entryability/EntryAbility.ets` | 应用入口 Ability |
| - [x] | 创建 Index 主页面 | P0 | EntryAbility | `pages/Index.ets` | Tab 导航容器 |
| - [x] | 实现底部 Tab 导航 | P0 | Index | `pages/Index.ets` | `Tabs` + `TabContent` |
| - [ ] | 配置 Tab 图标和标题 | P0 | Tab导航 | `resources/base/media/` | 准备 4 个 Tab 图标 |
| - [ ] | 实现页面转场动画 | P1 | Index | `pages/Index.ets` | `pageTransition()` |

### 2.10 UI 重构

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 用鸿蒙6最新UI重构App | P0 | 所有UI模块 | 全局 | 使用 HarmonyOS 6 最新设计规范 |

---

## Phase 3: 测试与优化 (Week 9-10)

### 3.1 单元测试

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 编写 HttpService 单元测试 | P0 | HTTP服务 | `test/HttpService.test.ets` | 模拟 HTTP 请求 |
| - [ ] | 编写 Repository 层单元测试 | P0 | Repository | `test/*Repository.test.ets` | Mock 数据层 |
| - [ ] | 编写 ViewModel 单元测试 | P1 | ViewModel | `test/*ViewModel.test.ets` | 状态变化测试 |
| - [ ] | 编写工具函数单元测试 | P1 | 工具类 | `test/Utils.test.ets` | 边界条件测试 |

### 3.2 集成测试

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 网关发现流程测试 | P0 | 网关模块 | `test/integration/Gateway.test.ets` | 端到端测试 |
| - [ ] | 对话流程测试 | P0 | 对话模块 | `test/integration/Chat.test.ets` | 发送接收消息 |
| - [ ] | 进程管理流程测试 | P1 | 进程模块 | `test/integration/Process.test.ets` | 查询、终止进程 |
| - [ ] | 页面导航测试 | P1 | 主框架 | `test/integration/Navigation.test.ets` | Tab 切换、页面跳转 |

### 3.3 UI 测试

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 组件渲染测试 | P1 | 所有组件 | `test/ui/Components.test.ets` | 快照测试 |
| - [ ] | 交互响应测试 | P1 | UI组件 | `test/ui/Interaction.test.ets` | 点击、输入事件 |
| - [ ] | 适配性测试 | P1 | 所有页面 | - | 不同分辨率设备 |

### 3.4 性能优化

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 优化消息列表渲染性能 | P0 | 对话模块 | `components/chat/MessageList.ets` | 虚拟列表、懒加载 |
| - [ ] | 优化网关扫描性能 | P1 | 网关模块 | `services/GatewayDiscoveryService.ets` | 并发控制、超时处理 |
| - [ ] | 优化内存占用 | P1 | 全局 | - | 内存泄漏检测 |
| - [ ] | 减少包体积 | P2 | 全局 | - | 资源压缩、代码分割 |

### 3.5 代码质量

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 配置代码规范检查 | P1 | 项目初始化 | `.eslintrc` | ESLint + ArkTS 规则 |
| - [ ] | 代码审查与重构 | P1 | 所有代码 | - | 消除重复代码 |
| - [ ] | 补充代码注释 | P1 | 所有代码 | - | 关键逻辑注释 |
| - [ ] | 生成 API 文档 | P2 | 所有代码 | `docs/` | 使用 TypeDoc |

---

## Phase 4: 发布准备 (Week 11-12)

### 4.1 资源完善

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 设计应用图标 | P0 | 项目初始化 | `AppScope/resources/base/media/` | 多尺寸图标 |
| - [ ] | 准备启动页素材 | P0 | 项目初始化 | `resources/base/media/` | LaunchPage 背景 |
| - [ ] | 完善字符串资源 | P0 | 所有页面 | `resources/base/element/string.json` | 中英文 |
| - [ ] | 完善颜色资源 | P0 | DesignTokens | `resources/base/element/color.json` | 主题色定义 |
| - [ ] | 准备截图素材 | P1 | UI完成 | `screenshots/` | 商店展示图 |

### 4.2 文档编写

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 编写 README.md | P0 | 项目完成 | `README.md` | 项目说明、使用指南 |
| - [ ] | 编写用户手册 | P1 | 功能完成 | `docs/USER_GUIDE.md` | 功能使用说明 |
| - [ ] | 编写开发文档 | P2 | 代码完成 | `docs/DEVELOPMENT.md` | 架构说明、扩展指南 |
| - [ ] | 编写更新日志 | P0 | 发布前 | `CHANGELOG.md` | 版本变更记录 |

### 4.3 打包与签名

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 配置签名证书 | P0 | 项目完成 | `build-profile.json5` | 发布证书配置 |
| - [ ] | 执行 release 构建 | P0 | 签名配置 | `entry/build/outputs/` | `Build → Build Hap` |
| - [ ] | 验证构建产物 | P0 | 构建完成 | `.app` 文件 | 安装测试 |
| - [ ] | 混淆代码配置 | P1 | 构建配置 | `obfuscation-rules.txt` | 启用代码混淆 |

### 4.4 商店上架

| 状态 | 任务 | 优先级 | 依赖 | 文件路径 | 关键代码提示 |
|------|------|--------|------|----------|--------------|
| - [ ] | 注册开发者账号 | P0 | 发布准备 | - | 华为开发者联盟 |
| - [ ] | 准备应用介绍文案 | P0 | 发布准备 | - | 应用商店描述 |
| - [ ] | 提交应用审核 | P0 | 构建完成 | - | AppGallery Connect |
| - [ ] | 处理审核反馈 | P0 | 提交审核 | - | 根据反馈修改 |

---

## 📊 任务统计

### 按阶段统计

| 阶段 | 任务数 | P0 | P1 | P2 |
|------|--------|----|----|----|
| Phase 1: 规划与基础 | 16 | 12 | 4 | 0 |
| Phase 2: 核心开发 | 56 | 38 | 16 | 2 |
| Phase 3: 测试与优化 | 14 | 3 | 11 | 0 |
| Phase 4: 发布准备 | 16 | 8 | 5 | 3 |
| **总计** | **102** | **61** | **36** | **5** |

### 按模块统计

| 模块 | 任务数 |
|------|--------|
| 项目初始化 | 5 |
| 基础架构 | 8 |
| 网络服务 | 6 |
| 存储服务 | 4 |
| 网关发现 | 4 |
| Repository | 9 |
| ViewModel | 10 |
| 通用组件 | 4 |
| 网关模块 | 7 |
| 对话模块 | 10 |
| 进程模块 | 5 |
| 设置模块 | 4 |
| 主框架 | 5 |
| 测试 | 10 |
| 发布 | 11 |

---

## 🔄 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-03-09 | v1.0 | 初始版本，基于 DESIGN.md 创建 |

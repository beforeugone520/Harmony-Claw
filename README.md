# Harmony Claw

OpenClaw Gateway Manager for HarmonyOS - 基于 HarmonyOS API 22 的网关管理应用。（未完善）



---

## 简介

Harmony Claw 是一个用于管理 OpenClaw 网关系统的 HarmonyOS 应用。它提供了网关自动发现、多 Agent 对话、进程监控、日程管理和记账追踪等功能。

## 功能特性（部分待实现）

### 网关管理
- 自动发现局域网内的 OpenClaw 网关
- 手动添加/编辑网关（IP:端口）
- 网关状态实时监控
- 快速连接切换

### 对话系统
- 创建和管理多 Agent 会话
- 发送和接收消息
- 消息历史记录
- 实时对话界面

### 进程监控
- 查看运行中的进程
- 显示 CPU 和内存占用
- 终止进程操作
- 实时数据刷新

### 日程管理
- 日程创建与编辑
- 日历视图展示
- 与系统日历同步
- 提醒通知

### 记账与追踪
- 日常收支记录
- 热量摄入追踪
- 数据统计展示

## 技术栈

| 类别 | 技术 |
|------|------|
| **平台** | HarmonyOS 6.0+ |
| **SDK** | API 22 (6.0.2) |
| **语言** | ArkTS 3.0+ |
| **开发模式** | Stage Model |
| **架构** | MVVM + Repository 模式 |

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
│       │   │   ├── Index.ets          # 主页面/Dashboard
│       │   │   ├── GatewayListPage.ets
│       │   │   ├── ChatPage.ets
│       │   │   ├── ProcessListPage.ets
│       │   │   ├── SchedulePage.ets
│       │   │   ├── AccountingPage.ets
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
│       │   ├── constants/             # 常量定义
│       │   └── utils/                 # 工具类
│       │
│       └── resources/                 # 模块资源
│
├── LICENSE                            # MIT 许可证
├── build-profile.json5                # 构建配置
└── oh-package.json5                   # 项目配置
```

## 快速开始

### 环境要求

- HarmonyOS SDK API 22
- DevEco Studio 5.0+
- Node.js 18+

### 构建和运行

```bash
# 克隆项目
git clone https://github.com/BeforeUgone/Harmony-Claw.git
cd Harmony-Claw

# 在 DevEco Studio 中打开:
# 1. File → Open → 选择项目目录
# 2. 同步项目 (Build → Clean and Rebuild Project)
# 3. 连接设备或启动模拟器
# 4. 运行 (Run → Run 'entry')
```

### 配置后端

确保 OpenClaw 网关服务在局域网内运行，或手动配置网关 IP 地址。


## 贡献指南

我们欢迎所有形式的贡献！

### 提交 Issue

- 使用清晰的标题描述问题
- 提供复现步骤
- 注明设备型号和系统版本

### 提交 PR

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 代码规范

- 使用 UpperCamelCase 命名类名
- 使用 lowerCamelCase 命名变量和方法
- 使用 UPPER_CASE 命名常量
- 遵循 ArkTS 编码规范

## 开源许可

本项目基于 [MIT License](LICENSE) 开源。

使用的开源组件：
- ArkUI - Apache 2.0 License
- HarmonyOS SDK - 华为开发者许可协议

## 作者

**BeforeUgone**

- GitHub: [@BeforeUgone](https://github.com/BeforeUgone)

---

<p align="center">
  Made with ❤️ for HarmonyOS
</p>

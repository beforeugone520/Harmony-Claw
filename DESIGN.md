# OpenClaw 网关管理应用 - 设计文档

> **版本**: v1.0  
> **HarmonyOS 版本**: 6.0.2 (API 22)  
> **ArkTS 版本**: 3.0+  
> **最后更新**: 2026-03-09

---

## 目录

1. [需求分析](#1-需求分析)
2. [功能模块划分](#2-功能模块划分)
3. [技术架构](#3-技术架构)
4. [UI/UX 设计规范](#4-uiux-设计规范)
5. [数据模型](#5-数据模型)
6. [API 接口设计](#6-api-接口设计)
7. [项目结构](#7-项目结构)

---

## 1. 需求分析

### 1.1 产品定位

一款专为 HarmonyOS 6 设计的 OpenClaw 网关管理应用，提供直观的图形界面来管理本地网络中的 OpenClaw AI 网关，支持对话交互、进程管理和实时监控。

### 1.2 用户画像

| 用户类型 | 特征 | 核心需求 |
|---------|------|---------|
| AI 开发者 | 本地部署 OpenClaw，需要频繁调试 | 快速连接、会话管理、进程监控 |
| 技术爱好者 | 搭建本地 AI 环境，追求便捷操作 | 美观界面、流畅体验、实时状态 |
| 企业用户 | 内部部署 OpenClaw 服务 | 多网关管理、稳定性、安全性 |

### 1.3 功能需求

#### 1.3.1 必须实现 (P0)

| 需求编号 | 功能 | 描述 | 验收标准 |
|---------|------|------|---------|
| R001 | 网关发现 | 局域网内自动发现 OpenClaw 网关 | 扫描 8333 端口，展示可用网关列表 |
| R002 | 手动连接 | 输入 IP:端口手动添加网关 | 支持 IP+端口输入，验证连接可用性 |
| R003 | 对话界面 | 类似 ChatGPT 的对话交互 | 支持文本输入、消息展示、历史记录 |
| R004 | 发送消息 | 通过 REST API 发送对话消息 | 异步发送，实时展示响应 |
| R005 | 会话列表 | 查看所有对话会话 | 展示会话标题、最后消息、时间 |
| R006 | 进程管理 | 查看运行中的进程/会话 | 展示进程状态、资源占用、支持终止 |

#### 1.3.2 应该实现 (P1)

| 需求编号 | 功能 | 描述 | 验收标准 |
|---------|------|------|---------|
| R007 | 实时监控 | 系统状态监控面板 | CPU、内存、网络实时数据展示 |
| R008 | 消息样式 | 富文本消息展示 | Markdown 渲染、代码高亮 |
| R009 | 历史记录 | 本地缓存对话历史 | 支持离线查看、搜索 |
| R010 | 多网关 | 支持多个网关切换 | 网关列表管理、快速切换 |

#### 1.3.3 可以实现 (P2)

| 需求编号 | 功能 | 描述 | 验收标准 |
|---------|------|------|---------|
| R011 | 语音输入 | HarmonyOS 语音转文字 | 调用系统语音能力 |
| R012 | 深色模式 | 自适应系统主题 | 跟随系统深色/浅色切换 |
| R013 | 桌面卡片 | Service Widget 快捷入口 | 1x2 / 2x2 尺寸卡片 |

### 1.4 非功能需求

| 类别 | 需求 | 指标 |
|-----|------|------|
| 性能 | 页面加载 | 首屏 < 1s，切换 < 300ms |
| 性能 | 消息响应 | 发送后 100ms 内展示 loading |
| 稳定性 | 异常处理 | 网络异常友好提示，自动重连 |
| 兼容性 | 设备支持 | Phone、Tablet、2in1 设备 |
| 体验 | 动画流畅 | 60fps，符合 HarmonyOS 动效规范 |

---

## 2. 功能模块划分

### 2.1 模块总览

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenClaw Gateway Manager                  │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ 网关管理 │  │ 对话中心 │  │ 进程监控 │  │ 系统设置 │    │
│  │ Gateway  │  │  Chat    │  │ Process  │  │ Settings │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
│       └─────────────┴─────────────┴─────────────┘           │
│                         │                                   │
│              ┌──────────┴──────────┐                       │
│              │     核心服务层       │                       │
│              │  (HTTP / Storage)   │                       │
│              └─────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块详细说明

#### 2.2.1 网关管理模块 (GatewayModule)

**职责**: 管理 OpenClaw 网关的生命周期

| 子功能 | 说明 | 优先级 |
|-------|------|-------|
| 自动发现 | mDNS/UDP 广播扫描局域网 8333 端口 | P0 |
| 手动添加 | IP + 端口输入表单，连接测试 | P0 |
| 网关列表 | 已保存网关的展示、编辑、删除 | P0 |
| 连接管理 | 当前活跃连接状态维护 | P0 |

#### 2.2.2 对话中心模块 (ChatModule)

**职责**: 提供对话交互界面

| 子功能 | 说明 | 优先级 |
|-------|------|-------|
| 会话列表 | 展示所有会话，支持搜索 | P0 |
| 聊天界面 | 消息气泡、输入框、发送按钮 | P0 |
| 消息管理 | 发送、接收、失败重试 | P0 |
| 新建会话 | 创建新对话会话 | P0 |

#### 2.2.3 进程监控模块 (ProcessModule)

**职责**: 展示和管理运行中的进程

| 子功能 | 说明 | 优先级 |
|-------|------|-------|
| 进程列表 | 展示所有活跃进程 | P0 |
| 进程详情 | 单个进程的详细信息 | P1 |
| 进程控制 | 终止、暂停、恢复进程 | P1 |
| 资源监控 | CPU、内存使用率图表 | P1 |

#### 2.2.4 系统设置模块 (SettingsModule)

**职责**: 应用配置和用户偏好

| 子功能 | 说明 | 优先级 |
|-------|------|-------|
| 主题设置 | 深色/浅色/跟随系统 | P1 |
| 缓存管理 | 清除本地缓存 | P2 |
| 关于页面 | 版本信息、开源协议 | P1 |

---

## 3. 技术架构

### 3.1 技术栈

| 层级 | 技术选型 | 说明 |
|-----|---------|------|
| 编程语言 | ArkTS | HarmonyOS 声明式 UI 语言 |
| UI 框架 | ArkUI | 声明式 UI 开发框架 |
| 状态管理 | AppStorage + @State | 组件状态 + 全局状态 |
| 网络请求 | @ohos.net.http | 系统 HTTP 客户端 |
| 本地存储 | @ohos.data.preferences | 轻量级键值存储 |
| 路由导航 | @ohos.router | 页面路由管理 |

### 3.2 架构模式: MVVM + Repository

```
┌────────────────────────────────────────────────────────────┐
│                         UI 层 (View)                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │ GatewayPage │ │  ChatPage   │ │     ProcessPage     │  │
│  └──────┬──────┘ └──────┬──────┘ └──────────┬──────────┘  │
│         │               │                    │             │
│         └───────────────┼────────────────────┘             │
│                         │                                  │
│              ┌──────────┴──────────┐                      │
│              │   ViewModel 层      │                      │
│              │  (@ObservedV2)      │                      │
│              └──────────┬──────────┘                      │
│                         │                                  │
│              ┌──────────┴──────────┐                      │
│              │   Repository 层     │                      │
│              │  (Data Repository)  │                      │
│              └──────────┬──────────┘                      │
│                         │                                  │
│         ┌───────────────┼───────────────┐                  │
│         ▼               ▼               ▼                  │
│  ┌────────────┐ ┌─────────────┐ ┌──────────────┐          │
│  │ Remote API │ │ Local Cache │ │ Preferences  │          │
│  └────────────┘ └─────────────┘ └──────────────┘          │
└────────────────────────────────────────────────────────────┘
```

### 3.3 核心组件设计

#### 3.3.1 网络层 (Network Layer)

```typescript
// HttpClient.ts - 统一的 HTTP 请求管理
class HttpClient {
  private baseURL: string;
  private timeout: number;
  
  constructor(config: HttpConfig);
  
  // 核心方法
  get<T>(path: string, params?: object): Promise<T>;
  post<T>(path: string, data?: object): Promise<T>;
  delete<T>(path: string): Promise<T>;
  
  // 网关专用
  setBaseURL(url: string): void;
  checkConnection(): Promise<boolean>;
}
```

#### 3.3.2 数据层 (Data Layer)

```typescript
// GatewayRepository.ts
class GatewayRepository {
  // 网关 CRUD
  getAllGateways(): Promise<Gateway[]>;
  addGateway(gateway: Gateway): Promise<void>;
  updateGateway(gateway: Gateway): Promise<void>;
  deleteGateway(id: string): Promise<void>;
  
  // 当前网关
  getCurrentGateway(): Gateway | null;
  setCurrentGateway(gateway: Gateway): void;
}

// ChatRepository.ts
class ChatRepository {
  // 会话管理
  getSessions(): Promise<Session[]>;
  createSession(): Promise<Session>;
  deleteSession(id: string): Promise<void>;
  
  // 消息管理
  getMessages(sessionId: string): Promise<Message[]>;
  sendMessage(sessionId: string, content: string): Promise<Message>;
}

// ProcessRepository.ts
class ProcessRepository {
  getProcesses(): Promise<Process[]>;
  getProcessDetail(id: string): Promise<ProcessDetail>;
  terminateProcess(id: string): Promise<void>;
}
```

#### 3.3.3 ViewModel 层

```typescript
// GatewayViewModel.ts
@ObservedV2
class GatewayViewModel {
  @Trace gateways: Gateway[] = [];
  @Trace isScanning: boolean = false;
  @Trace currentGateway: Gateway | null = null;
  
  async scanGateways(): Promise<void>;
  async addGateway(ip: string, port: number): Promise<void>;
  async connectGateway(gateway: Gateway): Promise<boolean>;
}

// ChatViewModel.ts
@ObservedV2
class ChatViewModel {
  @Trace sessions: Session[] = [];
  @Trace currentSession: Session | null = null;
  @Trace messages: Message[] = [];
  @Trace isSending: boolean = false;
  
  async loadSessions(): Promise<void>;
  async selectSession(id: string): Promise<void>;
  async sendMessage(content: string): Promise<void>;
  async createNewSession(): Promise<void>;
}
```

### 3.4 数据流设计

```
用户操作 → ViewModel方法 → Repository → 数据源 → 状态更新 → UI刷新
                                              ↑
                                        (响应式绑定)
```

---

## 4. UI/UX 设计规范

### 4.1 设计原则

遵循 HarmonyOS 6 **「自然、流畅、和谐」**的设计语言：

1. **自然交互** - 符合物理直觉的动画和反馈
2. **一镜到底** - 页面转场保持视觉连续性
3. **智能多窗** - 适配多种设备形态
4. **和谐色彩** - 采用 HarmonyOS 系统色板

### 4.2 色彩系统

```typescript
// DesignTokens.ets - 设计令牌
export class DesignTokens {
  // 主色调 - OpenClaw 品牌蓝
  static readonly BRAND_PRIMARY = '#2563EB';
  static readonly BRAND_SECONDARY = '#3B82F6';
  static readonly BRAND_LIGHT = '#DBEAFE';
  
  // 功能色
  static readonly SUCCESS = '#10B981';
  static readonly WARNING = '#F59E0B';
  static readonly ERROR = '#EF4444';
  static readonly INFO = '#6B7280';
  
  // 中性色 - 浅色模式
  static readonly LIGHT_BACKGROUND = '#FFFFFF';
  static readonly LIGHT_SURFACE = '#F3F4F6';
  static readonly LIGHT_BORDER = '#E5E7EB';
  static readonly LIGHT_TEXT_PRIMARY = '#111827';
  static readonly LIGHT_TEXT_SECONDARY = '#6B7280';
  
  // 中性色 - 深色模式
  static readonly DARK_BACKGROUND = '#0F172A';
  static readonly DARK_SURFACE = '#1E293B';
  static readonly DARK_BORDER = '#334155';
  static readonly DARK_TEXT_PRIMARY = '#F9FAFB';
  static readonly DARK_TEXT_SECONDARY = '#9CA3AF';
  
  // 用户消息气泡
  static readonly USER_BUBBLE = '#2563EB';
  static readonly USER_BUBBLE_TEXT = '#FFFFFF';
  
  // AI 消息气泡
  static readonly AI_BUBBLE_LIGHT = '#F3F4F6';
  static readonly AI_BUBBLE_DARK = '#1E293B';
}
```

### 4.3 字体规范

| 层级 | 大小 | 字重 | 用途 |
|-----|------|------|------|
| H1 | 24fp | Bold | 页面标题 |
| H2 | 20fp | Bold | 模块标题 |
| H3 | 17fp | Medium | 卡片标题 |
| Body | 16fp | Regular | 正文内容 |
| Caption | 14fp | Regular | 辅助文字 |
| Small | 12fp | Regular | 标签、时间 |

### 4.4 间距系统

```typescript
// Spacing.ets
export class Spacing {
  static readonly XS = 4;
  static readonly S = 8;
  static readonly M = 12;
  static readonly L = 16;
  static readonly XL = 20;
  static readonly XXL = 24;
  static readonly XXXL = 32;
  
  // 页面边距
  static readonly PAGE_HORIZONTAL = 16;
  static readonly PAGE_VERTICAL = 12;
}
```

### 4.5 圆角规范

| 组件 | 圆角值 | 说明 |
|-----|--------|------|
| 小标签 | 4vp | 状态标签 |
| 按钮 | 8vp | 普通按钮 |
| 输入框 | 12vp | 输入框 |
| 卡片 | 16vp | 内容卡片 |
| 页面 | 20vp | 底部面板 |
| 全屏 | 24vp | 全屏模态 |

### 4.6 动效规范

```typescript
// Animation.ets
export class Animation {
  // 时长
  static readonly DURATION_FAST = 150;
  static readonly DURATION_NORMAL = 300;
  static readonly DURATION_SLOW = 500;
  
  // 缓动曲线
  static readonly EASE_OUT = Curve.EaseOut;
  static readonly SPRING = Curve.Spring(mass: 1, stiffness: 200, damping: 20);
  static readonly INTERPOLATING = Curve.InterpolatingSpring(0, 1, 200, 20);
  
  // 转场
  static readonly PAGE_TRANSITION = PageTransitionEnter({
    duration: 300,
    curve: Curve.EaseOut
  });
}
```

### 4.7 页面布局

#### 4.7.1 主页面结构 (Bottom Tab Navigation)

```
┌─────────────────────────────────────────┐
│  状态栏 (沉浸)                           │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│              内容区域                    │
│         (根据 Tab 切换)                  │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│  🏠首页   💬对话   📊进程   ⚙️设置       │
│  (底部导航栏)                            │
├─────────────────────────────────────────┤
│  导航栏 (系统)                           │
└─────────────────────────────────────────┘
```

#### 4.7.2 对话页面布局

```
┌─────────────────────────────────────────┐
│  ← 会话名称                    ⋮ 更多   │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐   │
│  │ 🤖 你好！有什么可以帮助你的？     │   │
│  │     12:30                        │   │
│  └─────────────────────────────────┘   │
│       ┌───────────────────────────┐    │
│       │ 你好，请介绍一下 OpenClaw │ 🧑 │
│       │ 12:31                      │    │
│       └───────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🤖 OpenClaw 是一个...           │   │
│  │     12:31  ✓✓                  │   │
│  └─────────────────────────────────┘   │
│                                         │
├─────────────────────────────────────────┤
│  ┌─────────────────────┐ ┌───┐         │
│  │ 输入消息...          │ │ ➤ │         │
│  └─────────────────────┘ └───┘         │
└─────────────────────────────────────────┘
```

---

## 5. 数据模型

### 5.1 核心实体

```typescript
// models/Gateway.ets
export class Gateway {
  id: string;           // UUID
  name: string;         // 显示名称
  host: string;         // IP 地址
  port: number;         // 端口 (默认 8333)
  isOnline: boolean;    // 在线状态
  lastConnected: number; // 最后连接时间
  version?: string;     // 网关版本
  
  getUrl(): string {
    return `http://${this.host}:${this.port}`;
  }
}

// models/Session.ets
export class Session {
  id: string;           // 会话 ID
  title: string;        // 会话标题
  createdAt: number;    // 创建时间
  updatedAt: number;    // 最后更新时间
  messageCount: number; // 消息数量
  isActive: boolean;    // 是否活跃
}

// models/Message.ets
export enum MessageRole {
  USER = 'user',
  ASSISTANT = 'assistant',
  SYSTEM = 'system'
}

export enum MessageStatus {
  PENDING = 'pending',
  SENDING = 'sending',
  SENT = 'sent',
  FAILED = 'failed',
  STREAMING = 'streaming'
}

export class Message {
  id: string;               // 消息 ID
  sessionId: string;        // 所属会话
  role: MessageRole;        // 角色
  content: string;          // 内容
  timestamp: number;        // 时间戳
  status: MessageStatus;    // 状态
  errorMessage?: string;    // 错误信息
  metadata?: object;        // 额外元数据
}

// models/Process.ets
export enum ProcessStatus {
  RUNNING = 'running',
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  TERMINATED = 'terminated'
}

export class Process {
  id: string;              // 进程 ID
  name: string;            // 进程名称
  type: string;            // 进程类型
  status: ProcessStatus;   // 状态
  createdAt: number;       // 创建时间
  updatedAt: number;       // 更新时间
  progress?: number;       // 进度 (0-100)
  cpuUsage?: number;       // CPU 使用率
  memoryUsage?: number;    // 内存使用 (MB)
}

export class ProcessDetail extends Process {
  logs: string[];          // 日志输出
  parameters: object;      // 运行参数
  result?: object;         // 执行结果
}
```

### 5.2 DTO (Data Transfer Object)

```typescript
// dto/OpenClawAPI.ts

// 通用响应
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

// 网关信息响应
export interface GatewayInfoResponse {
  version: string;
  features: string[];
  max_context_length: number;
}

// 发送消息请求
export interface SendMessageRequest {
  message: string;
  session_id?: string;
  context?: Message[];
}

// 发送消息响应
export interface SendMessageResponse {
  message_id: string;
  content: string;
  session_id: string;
  timestamp: number;
}

// 会话列表响应
export interface SessionListResponse {
  sessions: SessionItem[];
  total: number;
}

export interface SessionItem {
  id: string;
  title: string;
  created_at: number;
  updated_at: number;
  message_count: number;
}

// 进程列表响应
export interface ProcessListResponse {
  processes: ProcessItem[];
}

export interface ProcessItem {
  id: string;
  name: string;
  type: string;
  status: string;
  created_at: number;
  updated_at: number;
  progress?: number;
  cpu_usage?: number;
  memory_usage?: number;
}
```

---

## 6. API 接口设计

### 6.1 OpenClaw 网关 API 规范

基于 RESTful 设计，假设 OpenClaw 网关提供以下端点：

#### 6.1.1 网关信息

| 方法 | 端点 | 描述 |
|-----|------|------|
| GET | `/api/info` | 获取网关信息 |

**响应示例**:
```json
{
  "version": "0.12.0",
  "features": ["chat", "process", "streaming"],
  "max_context_length": 8192
}
```

#### 6.1.2 会话管理

| 方法 | 端点 | 描述 |
|-----|------|------|
| GET | `/api/sessions` | 获取会话列表 |
| POST | `/api/sessions` | 创建新会话 |
| GET | `/api/sessions/{id}` | 获取会话详情 |
| DELETE | `/api/sessions/{id}` | 删除会话 |
| GET | `/api/sessions/{id}/messages` | 获取会话消息 |

#### 6.1.3 消息管理

| 方法 | 端点 | 描述 |
|-----|------|------|
| POST | `/api/sessions/{id}/messages` | 发送消息 |
| GET | `/api/messages/{id}` | 获取消息详情 |
| DELETE | `/api/messages/{id}` | 删除消息 |

**发送消息请求**:
```json
{
  "message": "你好，请介绍一下 OpenClaw",
  "stream": false
}
```

**发送消息响应**:
```json
{
  "message_id": "msg_abc123",
  "content": "你好！OpenClaw 是一个...",
  "session_id": "sess_xyz789",
  "timestamp": 1709876543210,
  "tokens_used": 150
}
```

#### 6.1.4 进程管理

| 方法 | 端点 | 描述 |
|-----|------|------|
| GET | `/api/processes` | 获取进程列表 |
| GET | `/api/processes/{id}` | 获取进程详情 |
| POST | `/api/processes/{id}/terminate` | 终止进程 |
| GET | `/api/processes/{id}/logs` | 获取进程日志 |

### 6.2 HTTP 客户端封装

```typescript
// services/HttpService.ets
import http from '@ohos.net.http';

export class HttpService {
  private httpClient: http.HttpClient;
  private baseURL: string = '';
  
  constructor() {
    this.httpClient = http.createHttp();
  }
  
  setBaseURL(url: string): void {
    this.baseURL = url.replace(/\/$/, '');
  }
  
  async get<T>(path: string, params?: Record<string, string>): Promise<T> {
    const url = this.buildURL(path, params);
    const response = await this.httpClient.request(url, {
      method: http.RequestMethod.GET,
      header: { 'Content-Type': 'application/json' }
    });
    return this.handleResponse<T>(response);
  }
  
  async post<T>(path: string, data?: object): Promise<T> {
    const url = this.baseURL + path;
    const response = await this.httpClient.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: data ? JSON.stringify(data) : undefined
    });
    return this.handleResponse<T>(response);
  }
  
  async delete<T>(path: string): Promise<T> {
    const url = this.baseURL + path;
    const response = await this.httpClient.request(url, {
      method: http.RequestMethod.DELETE,
      header: { 'Content-Type': 'application/json' }
    });
    return this.handleResponse<T>(response);
  }
  
  async checkConnection(): Promise<boolean> {
    try {
      await this.get('/api/info');
      return true;
    } catch {
      return false;
    }
  }
  
  private buildURL(path: string, params?: Record<string, string>): string {
    let url = this.baseURL + path;
    if (params) {
      const query = Object.entries(params)
        .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
        .join('&');
      url += '?' + query;
    }
    return url;
  }
  
  private handleResponse<T>(response: http.HttpResponse): T {
    if (response.responseCode !== 200) {
      throw new Error(`HTTP ${response.responseCode}: ${response.result}`);
    }
    return JSON.parse(response.result as string) as T;
  }
}
```

---

## 7. 项目结构

```
OpenClaw-Gateway-Manager/
├── AppScope/
│   └── resources/
│       └── base/
│           ├── element/
│           │   └── string.json
│           └── media/
│               └── app_icon.png
├── entry/
│   └── src/
│       └── main/
│           ├── ets/
│           │   ├── entryability/
│           │   │   └── EntryAbility.ets
│           │   ├── pages/
│           │   │   ├── Index.ets              # 主页面 (Tab 导航)
│           │   │   ├── gateway/
│           │   │   │   ├── GatewayListPage.ets
│           │   │   │   ├── GatewayDetailPage.ets
│           │   │   │   └── AddGatewayPage.ets
│           │   │   ├── chat/
│           │   │   │   ├── SessionListPage.ets
│           │   │   │   └── ChatPage.ets
│           │   │   ├── process/
│           │   │   │   └── ProcessListPage.ets
│           │   │   └── settings/
│           │   │       └── SettingsPage.ets
│           │   ├── components/
│           │   │   ├── common/
│           │   │   │   ├── LoadingView.ets
│           │   │   │   ├── EmptyView.ets
│           │   │   │   └── ErrorView.ets
│           │   │   ├── gateway/
│           │   │   │   ├── GatewayCard.ets
│           │   │   │   └── GatewayStatusBadge.ets
│           │   │   ├── chat/
│           │   │   │   ├── MessageBubble.ets
│           │   │   │   ├── MessageList.ets
│           │   │   │   ├── ChatInput.ets
│           │   │   │   └── SessionItem.ets
│           │   │   └── process/
│           │   │       ├── ProcessCard.ets
│           │   │       └── ProcessStatusIcon.ets
│           │   ├── viewmodels/
│           │   │   ├── GatewayViewModel.ets
│           │   │   ├── ChatViewModel.ets
│           │   │   └── ProcessViewModel.ets
│           │   ├── repositories/
│           │   │   ├── GatewayRepository.ets
│           │   │   ├── ChatRepository.ets
│           │   │   └── ProcessRepository.ets
│           │   ├── services/
│           │   │   ├── HttpService.ets
│           │   │   ├── StorageService.ets
│           │   │   └── GatewayDiscoveryService.ets
│           │   ├── models/
│           │   │   ├── Gateway.ets
│           │   │   ├── Session.ets
│           │   │   ├── Message.ets
│           │   │   └── Process.ets
│           │   ├── dto/
│           │   │   └── OpenClawAPI.ets
│           │   ├── constants/
│           │   │   ├── DesignTokens.ets
│           │   │   ├── Spacing.ets
│           │   │   ├── Animation.ets
│           │   │   └── ApiEndpoints.ets
│           │   └── utils/
│           │       ├── DateUtils.ets
│           │       └── NetworkUtils.ets
│           ├── resources/
│           │   └── base/
│           │       ├── element/
│           │       │   ├── color.json
│           │       │   ├── float.json
│           │       │   └── string.json
│           │       ├── media/
│           │       │   ├── ic_gateway.svg
│           │       │   ├── ic_chat.svg
│           │       │   ├── ic_process.svg
│           │       │   └── ic_settings.svg
│           │       └── theme.json
│           └── module.json5
├── build-profile.json5
├── hvigorfile.ts
├── oh-package.json5
└── README.md
```

---

## 附录

### A. 开发环境要求

| 工具 | 版本 |
|-----|------|
| DevEco Studio | 5.0.0+ |
| HarmonyOS SDK | API 12+ |
| Node.js | 18+ |
| TypeScript | 5.0+ |

### B. 参考资源

- [HarmonyOS 开发文档](https://developer.harmonyos.com/)
- [ArkTS 语言指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-get-started-0000001504769321-V3)
- [ArkUI 声明式 UI](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkui-overview-0000001504818876-V3)
- [OpenClaw API 文档](https://docs.openclaw.dev/)

### C. 命名规范

| 类型 | 规范 | 示例 |
|-----|------|------|
| 文件 | PascalCase.ets | `GatewayCard.ets` |
| 类 | PascalCase | `class GatewayViewModel` |
| 接口 | PascalCase | `interface ApiResponse` |
| 方法 | camelCase | `getAllGateways()` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 枚举 | PascalCase | `enum MessageStatus` |
| 变量 | camelCase | `gatewayList` |

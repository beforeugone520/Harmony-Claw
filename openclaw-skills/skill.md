# OpenClaw Agent Skills 总览

## 概述

本文档描述 OpenClaw 系统中用于数据管理和可视化的 Skills，供 Agent 查看和调用。

---

## 📊 Accounting Skill（记账热量管理）

### 基本信息
- **ID**: accounting-skill
- **名称**: 记账热量管理
- **版本**: 1.0.0
- **适用 Agent**: accounting-bot
- **数据文件**: `~/.openclaw/data/accounting.json`

### 工具列表

#### write_bill - 记录账单
记录一笔消费账单，支持热量追踪。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| date | string | 是 | 日期 YYYY-MM-DD |
| category | string | 是 | 类别：餐饮/交通/购物/娱乐/医疗/教育/其他 |
| amount | number | 是 | 消费金额 |
| currency | string | 否 | 货币，默认 CNY |
| items | string[] | 否 | 消费项目列表 |
| calories | number | 否 | 食物热量（大卡） |
| note | string | 否 | 备注 |

**示例调用**:
```json
{
  "date": "2026-03-10",
  "category": "餐饮",
  "amount": 35.5,
  "items": ["午餐"],
  "calories": 650,
  "note": "公司食堂"
}
```

#### read_bills - 读取账单
查询历史账单记录。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| startDate | string | 是 | 开始日期 YYYY-MM-DD |
| endDate | string | 是 | 结束日期 YYYY-MM-DD |
| category | string | 否 | 按类别筛选 |

#### get_stats - 获取统计
获取消费和热量统计数据。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | string | 否 | 周期：week/month/year，默认 month |

### 使用场景
- 记录日常消费
- 追踪饮食热量摄入
- 查看消费统计和趋势
- 分析支出分类占比

---

## 📅 Schedule Skill（日程管理）

### 基本信息
- **ID**: schedule-skill
- **名称**: 日程管理
- **版本**: 1.0.0
- **适用 Agent**: note-bot
- **数据文件**: `~/.openclaw/data/schedule.json`

### 工具列表

#### write_event - 添加日程
添加一条日程安排。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 事件标题 |
| description | string | 否 | 事件描述 |
| startTime | number | 是 | 开始时间，Unix时间戳（毫秒） |
| endTime | number | 是 | 结束时间，Unix时间戳（毫秒） |
| location | string | 否 | 地点 |
| category | string | 否 | 类别：工作/个人/健康/学习/社交/娱乐，默认"个人" |
| isAllDay | boolean | 否 | 是否为全天事件 |
| reminder | number | 否 | 提前提醒时间（分钟），默认15 |

**示例调用**:
```json
{
  "title": "项目评审会议",
  "description": "与团队讨论Q2计划",
  "startTime": 1700000000000,
  "endTime": 1700003600000,
  "location": "会议室A",
  "category": "工作",
  "reminder": 15
}
```

#### read_events - 读取日程
查询日程列表。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| date | string | 否 | 日期 YYYY-MM-DD |
| includePast | boolean | 否 | 是否包含过去日程，默认 false |

#### mark_synced - 标记已同步
标记日程已同步到系统日历。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| eventId | string | 是 | 事件ID |

### 使用场景
- 记录日程安排
- 管理会议和活动
- 设置提醒
- 同步到系统日历

---

## 🔧 通用说明

### 数据存储

所有数据以 JSON 格式存储在网关服务器：

```
~/.openclaw/
├── data/
│   ├── accounting.json    # 记账数据
│   └── schedule.json      # 日程数据
└── skills/
    ├── accounting-skill/
    └── schedule-skill/
```

### API 端点

Bridge Server 提供以下 REST API：

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/v1/data/accounting` | GET | 获取记账数据 |
| `/api/v1/data/accounting` | POST | 添加账单 |
| `/api/v1/data/accounting/stats` | GET | 获取统计 |
| `/api/v1/data/schedule` | GET | 获取日程 |
| `/api/v1/data/schedule` | POST | 添加日程 |
| `/api/v1/data/schedule/{id}/sync` | PUT | 标记已同步 |

### Agent 调用方式

Agent 通过 Bridge Server 调用 Skill 工具：

1. 用户发送消息给 Agent
2. Agent 解析意图，确定需要调用的工具
3. Agent 构造参数，调用对应工具
4. 工具写入数据到 JSON 文件
5. Agent 返回确认消息给用户
6. APP 通过 API 读取数据展示

### 注意事项

1. **日期格式**: 统一使用 `YYYY-MM-DD`
2. **时间戳**: Unix 时间戳为毫秒级（13位）
3. **类别枚举**: 严格使用预定义的类别值
4. **数据持久化**: 所有写入操作自动保存到文件
5. **并发安全**: 同一时间只有一个进程写入

---

## 📱 APP 集成

Harmony-Claw APP 通过 HTTP API 与 Bridge Server 通信：

```
APP (ArkTS)
  ↓ HTTP API
Bridge Server (Node.js)
  ↓ 调用 Python 工具
Skill Tools
  ↓ 读写
JSON 数据文件
```

APP 功能：
- 记账热量页面：统计卡片、折线图、饼图、账单列表
- 日程管理页面：日历视图、事件列表、同步按钮

---

*文档版本: 1.0.0*
*更新日期: 2026-03-10*

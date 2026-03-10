# OpenClaw Agent 数据管理与可视化功能

本文档描述了新实现的 Agent 数据管理和可视化功能。

## 概述

该功能实现了 accounting-bot（记账算热量）和 note-bot（日程记录）的数据持久化、可视化展示和日历同步功能。

## 文件结构

### APP 端文件（Harmony-Claw）

#### 1. 数据模型
- `entry/src/main/ets/models/AccountingModels.ets` - 记账与热量数据模型
- `entry/src/main/ets/models/ScheduleModels.ets` - 日程管理数据模型

#### 2. 数据仓库
- `entry/src/main/ets/repositories/AccountingRepository.ets` - 记账数据仓库
- `entry/src/main/ets/repositories/ScheduleRepository.ets` - 日程数据仓库

#### 3. 视图模型
- `entry/src/main/ets/viewmodels/AccountingViewModel.ets` - 记账视图模型
- `entry/src/main/ets/viewmodels/ScheduleViewModel.ets` - 日程视图模型

#### 4. 图表组件
- `entry/src/main/ets/components/charts/LineChart.ets` - 折线图组件（热量趋势）
- `entry/src/main/ets/components/charts/PieChart.ets` - 饼图组件（支出分类）

#### 5. 服务
- `entry/src/main/ets/services/CalendarSyncService.ets` - 日历同步服务

#### 6. 页面
- `entry/src/main/ets/pages/AccountingPage.ets` - 记账热量管理页面
- `entry/src/main/ets/pages/SchedulePage.ets` - 日程管理页面

#### 7. 配置文件修改
- `entry/src/main/ets/constants/ApiEndpoints.ets` - 添加数据 API 端点
- `entry/src/main/resources/base/profile/main_pages.json` - 注册新页面
- `entry/src/main/module.json5` - 添加日历权限
- `entry/src/main/resources/base/element/string.json` - 添加权限说明
- `entry/src/main/ets/pages/Index.ets` - 添加导航入口

### 网关端 Skill 文件

#### Accounting Skill
- `openclaw-skills/accounting-skill/skill.json` - Skill 配置
- `openclaw-skills/accounting-skill/tools/write_bill.py` - 写入账单工具
- `openclaw-skills/accounting-skill/tools/read_stats.py` - 读取统计工具
- `openclaw-skills/accounting-skill/prompts/accounting.md` - Agent 提示词

#### Schedule Skill
- `openclaw-skills/schedule-skill/skill.json` - Skill 配置
- `openclaw-skills/schedule-skill/tools/write_event.py` - 写入日程工具
- `openclaw-skills/schedule-skill/tools/read_events.py` - 读取日程工具
- `openclaw-skills/schedule-skill/tools/mark_synced.py` - 标记同步状态工具
- `openclaw-skills/schedule-skill/prompts/schedule.md` - Agent 提示词

## 功能说明

### 记账热量管理 (AccountingPage)

#### 功能特性
1. **统计卡片展示**
   - 本月支出总额
   - 今日热量摄入
   - 月均热量摄入

2. **热量趋势图**
   - 最近7天热量摄入折线图
   - 显示目标热量参考线

3. **支出分类饼图**
   - 按类别展示支出占比
   - 支持图例显示

4. **账单明细列表**
   - 显示最近20条账单
   - 包含类别图标、金额、热量、备注

#### 数据结构
```json
{
  "version": "1.0",
  "updatedAt": 1700000000000,
  "bills": [
    {
      "id": "bill_001",
      "date": "2026-03-10",
      "category": "餐饮",
      "amount": 35.5,
      "currency": "CNY",
      "items": ["午餐"],
      "calories": 650,
      "note": "公司食堂",
      "createdAt": 1700000000000
    }
  ],
  "dailyStats": [...],
  "monthlyStats": [...]
}
```

### 日程管理 (SchedulePage)

#### 功能特性
1. **日历视图**
   - 月历展示，支持切换月份
   - 日期下方显示事件标记点
   - 今日高亮显示
   - 选中日期高亮

2. **日程列表**
   - 选中日期的事件列表
   - 今日日程汇总
   - 显示同步状态图标

3. **日历同步**
   - 一键同步未同步的日程到系统日历
   - 显示同步状态
   - 支持批量同步

#### 数据结构
```json
{
  "version": "1.0",
  "updatedAt": 1700000000000,
  "events": [
    {
      "id": "event_001",
      "title": "项目评审会议",
      "description": "与团队讨论Q2计划",
      "startTime": 1700000000000,
      "endTime": 1700003600000,
      "location": "会议室A",
      "category": "工作",
      "isAllDay": false,
      "recurrence": null,
      "reminder": 15,
      "syncedToCalendar": false,
      "createdAt": 1700000000000
    }
  ],
  "categories": ["工作", "个人", "健康", "学习", "社交", "娱乐"]
}
```

## API 端点

### 记账 API
- `GET /api/v1/data/accounting` - 获取所有记账数据
- `POST /api/v1/data/accounting` - 添加账单记录
- `GET /api/v1/data/accounting/stats` - 获取统计信息

### 日程 API
- `GET /api/v1/data/schedule` - 获取所有日程
- `POST /api/v1/data/schedule` - 添加日程
- `PUT /api/v1/data/schedule/{id}/sync` - 标记日程已同步

## 使用说明

### 1. 安装 Skill

将 `openclaw-skills` 目录复制到网关服务器的 `~/.openclaw/skills/` 目录：

```bash
# 在网关服务器上执行
mkdir -p ~/.openclaw/skills
mkdir -p ~/.openclaw/data

# 复制 skill 文件
cp -r openclaw-skills/accounting-skill ~/.openclaw/skills/
cp -r openclaw-skills/schedule-skill ~/.openclaw/skills/

# 设置权限
chmod +x ~/.openclaw/skills/accounting-skill/tools/*.py
chmod +x ~/.openclaw/skills/schedule-skill/tools/*.py
```

### 2. 配置 Agent

在 accounting-bot 和 note-bot 的 AGENTS.md 中引用相应的 Skill。

### 3. 部署网关 API

在 Bridge Server 中添加对应的 API 端点，将 HTTP 请求转发到 Skill 工具。

### 4. 运行 APP

在 DevEco Studio 中构建并运行 Harmony-Claw 项目，即可看到新的记账热量和日程管理入口。

## 数据存储

数据默认存储在网关服务器的以下位置：
- 记账数据：`~/.openclaw/data/accounting.json`
- 日程数据：`~/.openclaw/data/schedule.json`

## 待办事项

### 网关端实现
1. Bridge Server 需要添加数据 API 端点
2. 实现 HTTP 请求到 Skill 工具的转发
3. 添加数据验证和错误处理

### APP 端增强
1. 添加账单和日程的编辑/删除功能
2. 实现数据筛选和搜索
3. 添加更多图表类型（柱状图、面积图）
4. 实现离线数据缓存

### 日历同步
1. 实现完整的 HarmonyOS CalendarKit 集成
2. 添加权限请求处理
3. 支持双向同步（系统日历 → APP）

## 技术栈

- **前端**：ArkTS / ArkUI (HarmonyOS)
- **图表**：Canvas 自定义绘制
- **后端**：Python 3
- **数据存储**：JSON 文件
- **API**：RESTful HTTP API

## 作者

OpenClaw Team

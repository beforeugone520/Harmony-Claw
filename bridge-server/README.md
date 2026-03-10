# OpenClaw Bridge Server

Bridge Server for Harmony-Claw App，提供 OpenClaw Agent 和进程监控的 REST API。

## 功能

- **Agent 管理**: 扫描 `~/.openclaw/agents/` 目录，提供 Agent 列表和详情
- **进程监控**: 获取系统进程信息（Node.js、OpenClaw 相关进程）
- **进程控制**: 支持终止进程

## 安装与启动

```bash
cd bridge-server
npm install  # 或 yarn
npm start
```

服务将在端口 **8333** 启动。

## API 端点

### Agent
- `GET /api/v1/agents` - 获取所有 Agent
- `GET /api/v1/agents/:id` - 获取 Agent 详情
- `GET /api/v1/agents/:id/status` - 获取 Agent 状态
- `GET /api/v1/agents/:id/metrics` - 获取 Agent 指标
- `POST /api/v1/agents/:id/send` - 发送消息给 Agent

### Process (进程监控)
- `GET /api/v1/processes` - 获取所有进程
- `GET /api/v1/processes/:id` - 获取进程详情
- `POST /api/v1/processes/:id/restart` - 重启进程
- `DELETE /api/v1/processes/:id/terminate` - 终止进程

## 配置

- `PORT` - 服务端口 (默认: 8333)
- `OPENCLAW_HOME` - OpenClaw 配置目录 (默认: `~/.openclaw`)

## Agent 目录结构

Bridge Server 扫描 `~/.openclaw/agents/` 下的文件夹作为 Agent：

```
~/.openclaw/
└── agents/
    ├── main/
    │   └── identity.json
    ├── learning/
    │   └── identity.json
    ├── note/
    │   └── identity.json
    └── ...
```

`identity.json` 格式:
```json
{
  "name": "Main Agent",
  "emoji": "🤖",
  "theme": "blue"
}
```

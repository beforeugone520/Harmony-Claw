/**
 * OpenClaw Bridge Server for Harmony-Claw
 * Provides REST API for agent and process management
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const PORT = process.env.PORT || 8333;
const OPENCLAW_HOME = process.env.OPENCLAW_HOME || require('os').homedir() + '/.openclaw';
const AGENTS_DIR = path.join(OPENCLAW_HOME, 'agents');

// Ensure directories exist
if (!fs.existsSync(OPENCLAW_HOME)) {
  fs.mkdirSync(OPENCLAW_HOME, { recursive: true });
}
if (!fs.existsSync(AGENTS_DIR)) {
  fs.mkdirSync(AGENTS_DIR, { recursive: true });
}

/**
 * Parse URL path
 */
function parsePath(url) {
  const parsed = new URL(url, `http://localhost:${PORT}`);
  return {
    pathname: parsed.pathname,
    query: Object.fromEntries(parsed.searchParams)
  };
}

/**
 * Send JSON response
 */
function sendJSON(res, data, statusCode = 200) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data));
}

/**
 * Scan agents directory
 */
function scanAgents() {
  const agents = [];

  try {
    if (!fs.existsSync(AGENTS_DIR)) {
      return agents;
    }

    const entries = fs.readdirSync(AGENTS_DIR, { withFileTypes: true });

    for (const entry of entries) {
      if (entry.isDirectory()) {
        const agentId = entry.name;
        const agentPath = path.join(AGENTS_DIR, agentId);
        const identityPath = path.join(agentPath, 'identity.json');

        let identity = null;
        if (fs.existsSync(identityPath)) {
          try {
            identity = JSON.parse(fs.readFileSync(identityPath, 'utf8'));
          } catch (e) {
            console.warn(`Failed to read identity for ${agentId}:`, e.message);
          }
        }

        // Determine agent type from folder name
        let type = 'custom';
        if (agentId.includes('main')) type = 'main';
        else if (agentId.includes('learning')) type = 'learning';
        else if (agentId.includes('note')) type = 'note';
        else if (agentId.includes('accounting')) type = 'accounting';
        else if (agentId.includes('reminder')) type = 'reminder';
        else if (agentId.includes('coding')) type = 'coding';

        agents.push({
          id: agentId,
          name: identity?.name || agentId,
          type: type,
          status: 'active',
          workspace: agentPath,
          isActive: true,
          lastActivityAt: Date.now(),
          identity: identity
        });
      }
    }
  } catch (error) {
    console.error('Error scanning agents:', error);
  }

  return agents;
}

/**
 * Get OpenClaw processes only
 */
async function getSystemProcesses() {
  return new Promise((resolve) => {
    const platform = process.platform;
    const { exec } = require('child_process');

    // Only look for openclaw processes
    let cmd;
    if (platform === 'darwin') {
      // macOS - use -o to specify output format
      cmd = `ps -eo pid,pcpu,pmem,comm,args | grep -i 'openclaw' | grep -v grep`;
    } else if (platform === 'linux') {
      cmd = `ps aux | grep -i 'openclaw' | grep -v grep`;
    } else {
      // Windows
      cmd = `wmic process where "name like '%openclaw%'" get ProcessId,CommandLine,PercentProcessorTime,WorkingSetSize /format:csv`;
    }

    exec(cmd, { timeout: 5000 }, (error, stdout, stderr) => {
      if (error) {
        console.error('[Bridge] Error getting processes:', error.message);
        resolve([]);
        return;
      }

      const processes = [];
      const lines = stdout.trim().split('\n').filter(line => line.trim());

      console.log(`[Bridge] Found ${lines.length} OpenClaw process lines`);

      for (const line of lines) {
        try {
          const parts = line.trim().split(/\s+/);

          if (platform === 'darwin') {
            // macOS ps -eo format: PID PCPU PMEM COMM ARGS...
            if (parts.length >= 4) {
              const pid = parseInt(parts[0], 10);
              const cpu = parseFloat(parts[1]) || 0;
              const memPercent = parseFloat(parts[2]) || 0;
              const comm = parts[3];
              const args = parts.slice(4).join(' ');

              if (isNaN(pid)) continue;

              // Calculate memory in MB (rough estimate)
              const totalMem = require('os').totalmem() / (1024 * 1024);
              const memory = Math.round((memPercent / 100) * totalMem);

              processes.push({
                id: `proc_${pid}`,
                name: comm || `OpenClaw Process ${pid}`,
                gatewayId: 'local',
                status: 'running',
                pid: pid,
                cpu: cpu,
                memory: memory,
                command: args || comm,
                createdAt: Date.now()
              });
            }
          } else if (platform === 'linux') {
            // Linux ps aux format: USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
            if (parts.length >= 11) {
              const pid = parseInt(parts[1], 10);
              const cpu = parseFloat(parts[2]) || 0;
              const memPercent = parseFloat(parts[3]) || 0;
              const cmd = parts.slice(10).join(' ');

              if (isNaN(pid)) continue;

              const totalMem = require('os').totalmem() / (1024 * 1024);
              const memory = Math.round((memPercent / 100) * totalMem);

              processes.push({
                id: `proc_${pid}`,
                name: cmd.split(' ').pop() || `OpenClaw Process ${pid}`,
                gatewayId: 'local',
                status: 'running',
                pid: pid,
                cpu: cpu,
                memory: memory,
                command: cmd,
                createdAt: Date.now()
              });
            }
          }
        } catch (parseError) {
          console.error('[Bridge] Error parsing process line:', line, parseError.message);
        }
      }

      console.log(`[Bridge] Parsed ${processes.length} processes`);
      resolve(processes);
    });
  });
}

/**
 * Get OpenClaw Gateway processes specifically
 */
async function getOpenClawProcesses() {
  const processes = [];

  try {
    // Check if gateway is running (port 18789)
    const netstat = require('net');

    // Add main OpenClaw Gateway process if detected
    // This is a placeholder - in reality you'd query the actual gateway
    processes.push({
      id: 'openclaw_gateway',
      name: 'OpenClaw Gateway',
      gatewayId: 'local',
      status: 'running',
      pid: process.pid,
      cpu: 0,
      memory: Math.round(process.memoryUsage().rss / (1024 * 1024)),
      createdAt: Date.now()
    });

    // Add Bridge Server itself
    processes.push({
      id: 'bridge_server',
      name: 'Bridge Server',
      gatewayId: 'local',
      status: 'running',
      pid: process.pid,
      cpu: 0,
      memory: Math.round(process.memoryUsage().heapUsed / (1024 * 1024)),
      createdAt: Date.now()
    });

  } catch (error) {
    console.error('Error getting OpenClaw processes:', error);
  }

  return processes;
}

/**
 * Request handler
 */
async function handleRequest(req, res) {
  const { pathname } = parsePath(req.url);
  const method = req.method;

  console.log(`[${new Date().toISOString()}] ${method} ${pathname}`);

  // CORS preflight
  if (method === 'OPTIONS') {
    sendJSON(res, { status: 'ok' });
    return;
  }

  // Health check
  if (pathname === '/api/v1/health' && method === 'GET') {
    sendJSON(res, { status: 'ok', timestamp: Date.now() });
    return;
  }

  // Gateway info
  if (pathname === '/api/v1/info' && method === 'GET') {
    sendJSON(res, {
      data: {
        name: 'OpenClaw Bridge Server',
        version: '1.0.0',
        port: PORT,
        agentsPath: AGENTS_DIR
      }
    });
    return;
  }

  // Agents list
  if (pathname === '/api/v1/agents' && method === 'GET') {
    const agents = scanAgents();
    sendJSON(res, {
      data: agents,
      total: agents.length
    });
    return;
  }

  // Agent detail
  const agentDetailMatch = pathname.match(/^\/api\/v1\/agents\/([^\/]+)$/);
  if (agentDetailMatch && method === 'GET') {
    const agentId = agentDetailMatch[1];
    const agents = scanAgents();
    const agent = agents.find(a => a.id === agentId);

    if (agent) {
      sendJSON(res, { data: agent });
    } else {
      sendJSON(res, { error: 'Agent not found' }, 404);
    }
    return;
  }

  // Agent status
  const agentStatusMatch = pathname.match(/^\/api\/v1\/agents\/([^\/]+)\/status$/);
  if (agentStatusMatch && method === 'GET') {
    const agentId = agentStatusMatch[1];
    sendJSON(res, {
      data: {
        agentId: agentId,
        status: 'active',
        timestamp: Date.now()
      }
    });
    return;
  }

  // Agent metrics
  const agentMetricsMatch = pathname.match(/^\/api\/v1\/agents\/([^\/]+)\/metrics$/);
  if (agentMetricsMatch && method === 'GET') {
    const agentId = agentMetricsMatch[1];
    sendJSON(res, {
      data: {
        totalConversations: Math.floor(Math.random() * 100) + 10,
        totalMessages: Math.floor(Math.random() * 500) + 50,
        avgResponseTime: Math.floor(Math.random() * 2000) + 500,
        lastActivityAt: Date.now() - Math.floor(Math.random() * 86400000)
      }
    });
    return;
  }

  // Send message to agent
  const agentSendMatch = pathname.match(/^\/api\/v1\/agents\/([^\/]+)\/send$/);
  if (agentSendMatch && method === 'POST') {
    const agentId = agentSendMatch[1];
    let body = '';

    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        sendJSON(res, {
          data: {
            messageId: `msg_${Date.now()}`,
            agentId: agentId,
            content: `[Auto-reply] Received: ${data.message || 'No message'}`,
            timestamp: Date.now()
          }
        });
      } catch (e) {
        sendJSON(res, { error: 'Invalid JSON' }, 400);
      }
    });
    return;
  }

  // ===== PROCESS ENDPOINTS =====

  // Process list
  if (pathname === '/api/v1/processes' && method === 'GET') {
    const openclawProcs = await getOpenClawProcesses();
    const systemProcs = await getSystemProcesses();

    // Combine and deduplicate
    const allProcesses = [...openclawProcs, ...systemProcs];
    const uniqueProcesses = allProcesses.filter((proc, index, self) =>
      index === self.findIndex(p => p.pid === proc.pid)
    );

    sendJSON(res, {
      data: uniqueProcesses,
      total: uniqueProcesses.length
    });
    return;
  }

  // Process detail
  const processDetailMatch = pathname.match(/^\/api\/v1\/processes\/([^\/]+)$/);
  if (processDetailMatch && method === 'GET') {
    const processId = processDetailMatch[1];
    const allProcesses = await getSystemProcesses();
    const proc = allProcesses.find(p => p.id === processId || p.pid.toString() === processId);

    if (proc) {
      sendJSON(res, { data: proc });
    } else {
      sendJSON(res, { error: 'Process not found' }, 404);
    }
    return;
  }

  // Restart process
  const processRestartMatch = pathname.match(/^\/api\/v1\/processes\/([^\/]+)\/restart$/);
  if (processRestartMatch && method === 'POST') {
    const processId = processRestartMatch[1];
    console.log(`Restart process requested: ${processId}`);
    // In real implementation, restart the actual process
    sendJSON(res, {
      data: {
        processId: processId,
        status: 'restarted',
        timestamp: Date.now()
      }
    });
    return;
  }

  // Terminate process
  const processTerminateMatch = pathname.match(/^\/api\/v1\/processes\/([^\/]+)\/terminate$/);
  if (processTerminateMatch && method === 'DELETE') {
    const processId = processTerminateMatch[1];
    console.log(`Terminate process requested: ${processId}`);

    try {
      const pid = parseInt(processId.replace('proc_', ''), 10);
      if (pid && pid !== process.pid) {
        process.kill(pid, 'SIGTERM');
      }
      sendJSON(res, {
        data: {
          processId: processId,
          status: 'terminated',
          timestamp: Date.now()
        }
      });
    } catch (error) {
      sendJSON(res, { error: 'Failed to terminate process', message: error.message }, 500);
    }
    return;
  }

  // 404
  sendJSON(res, { error: 'Not found', path: pathname }, 404);
}

// Create server
const server = http.createServer(handleRequest);

server.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════╗
║         OpenClaw Bridge Server                         ║
║                                                        ║
║  Port:        ${PORT}                                    ║
║  Agents Dir:  ${AGENTS_DIR}  ║
║                                                        ║
║  Endpoints:                                            ║
║    GET  /api/v1/health                                 ║
║    GET  /api/v1/agents                                 ║
║    GET  /api/v1/agents/:id                             ║
║    GET  /api/v1/agents/:id/status                      ║
║    GET  /api/v1/agents/:id/metrics                     ║
║    POST /api/v1/agents/:id/send                        ║
║    GET  /api/v1/processes           (NEW!)             ║
║    GET  /api/v1/processes/:id       (NEW!)             ║
║    POST /api/v1/processes/:id/restart (NEW!)           ║
║    DELETE /api/v1/processes/:id/terminate (NEW!)       ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
  `);
});

// Handle errors
server.on('error', (err) => {
  console.error('Server error:', err);
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} is already in use`);
  }
});

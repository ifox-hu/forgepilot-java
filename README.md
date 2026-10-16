# ForgePilot

ForgePilot 是一个基于 Java 21 的本地 AI 编程代理。它可以直接理解当前项目上下文，调用文件、搜索、Shell、Git worktree 等工具完成代码修改和调试，并提供终端、单次命令和 Web 控制台三种运行方式。

## 功能概览

| 能力 | 说明 |
| --- | --- |
| 模型接入 | Anthropic、OpenAI 和 OpenAI-compatible 接口 |
| 代码工具 | 文件读写、精确编辑、Glob/Grep 搜索、Shell 命令和权限确认 |
| 上下文管理 | 会话恢复、项目记忆、上下文压缩和工具结果预算 |
| 扩展机制 | MCP、Skill 和 Hook |
| 多 Agent | 子 Agent、团队任务板、消息邮箱和 Git worktree 隔离 |
| 运行模式 | TUI、非交互式单次执行、HTTP/WebSocket 远程控制台 |

## 环境要求

- Java 21+
- Gradle 8+（或使用仓库中的 Gradle Wrapper）
- Windows 下命令工具需要可用的 Bash；Linux/macOS 可直接使用系统 Bash
- 一个兼容的模型 API 和 API Key

## 快速开始

### 1. 配置模型

复制配置模板并填写模型服务信息：

```powershell
Copy-Item config.example.yaml .mewcode/config.yaml
```

```yaml
providers:
  - name: default
    protocol: openai-compat
    base_url: https://your-api-host/v1
    api_key:
    model: your-model-id
```

`api_key` 留空时会按协议自动读取环境变量：

| protocol | 环境变量 |
| --- | --- |
| `anthropic` | `ANTHROPIC_API_KEY` |
| `openai` / `openai-compat` | `OPENAI_API_KEY` |

配置文件默认按以下顺序查找并合并：`providers` 会整体替换，MCP 服务按 `name` 覆盖，Hooks 追加，其他非空字段覆盖前面：

1. `~/.mewcode/config.yaml`
2. `./.mewcode/config.yaml`
3. `./.mewcode/config.local.yaml`

也可以通过 `MEWCODE_CONFIG` 环境变量指定默认配置文件，或在启动时传入配置路径。

### 2. 构建和测试

```powershell
./gradlew.bat test shadowJar
```

生成的可执行 JAR 位于 `build/libs/mewcode.jar`。

### 3. 启动 Web 控制台

```powershell
./start-project.ps1
```

打开 <http://localhost:18888>。服务在后台运行，关闭终端不会停止服务。

常用参数：

```powershell
# 停止服务、执行测试、重新打包，再启动
./start-project.ps1 -Rebuild

# 只停止服务
./start-project.ps1 -Stop
```

`-JavaHome` 和 `-GradleHome` 可指定其他安装路径。首次运行前需要先构建，或直接使用 `-Rebuild`。Windows 会锁住正在运行的 JAR，重新打包前请先停止服务。

远程服务日志和 PID 文件位于 `.mewcode/remote.stdout.log`、`.mewcode/remote.stderr.log` 和 `.mewcode/remote.pid`。

## 启动命令

```powershell
# 终端交互模式
java -jar build/libs/mewcode.jar

# 非交互式执行
java -jar build/libs/mewcode.jar -p "请解释当前项目结构"

# 输出 JSON 事件流
java -jar build/libs/mewcode.jar -p "修复编译错误" --output-format stream-json

# 启动远程控制台
java -jar build/libs/mewcode.jar --remote

# 指定监听端口
java -jar build/libs/mewcode.jar --remote=:28888

# 指定配置文件
java -jar build/libs/mewcode.jar .mewcode/config.local.yaml
```

## 权限模式

`permission_mode` 控制写入和命令类工具是否需要确认：

| 模式 | 行为 |
| --- | --- |
| `default` | 读取自动执行，写入和命令需要确认 |
| `accept_edits` | 文件编辑自动执行，命令需要确认 |
| `bypass` | 全部自动执行，适合可信沙箱或临时环境 |

`.mewcode/` 已加入 Git 忽略规则，真实密钥、会话记录和本地运行数据不会提交到仓库。

## 安全提示

不要提交真实 API Key、会话记录、运行日志或本地配置。发布前请使用 `git grep` 检查密钥；如果密钥已经暴露，请立即吊销并生成新 Key。

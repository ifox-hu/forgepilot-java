# ForgePilot

ForgePilot 是一个基于 Java 21 的 AI 编程代理，支持终端交互、Web 控制台、文件和命令工具、MCP 扩展、长期记忆、上下文压缩以及多 Agent 协作。

## 特性

- Anthropic、OpenAI 和 OpenAI-compatible 模型接口
- 文件读写、代码搜索、Shell 命令和权限确认
- MCP、Skill、Hook 扩展机制
- 会话恢复、上下文压缩和项目记忆
- 子 Agent、团队任务板和 Git worktree 隔离
- TUI、单次命令和 WebSocket 远程模式

## 环境要求

- Java 21+
- Gradle 8+（或使用仓库中的 Gradle Wrapper）
- Windows 下命令工具需要可用的 Bash；Linux/macOS 可直接使用系统 Bash
- 一个兼容的模型 API 和 API Key

## 配置

复制配置模板并填写模型服务信息：

```powershell
Copy-Item config.example.yaml .mewcode/config.yaml
```

也可以通过 `OPENAI_API_KEY` 等环境变量提供密钥。`.mewcode/` 已加入 Git 忽略规则，真实密钥不会提交到仓库。

## 构建和测试

```powershell
./gradlew.bat test shadowJar
```

生成的可执行 JAR 位于 `build/libs/mewcode.jar`。

## 启动

```powershell
./start-project.ps1
```

打开 http://localhost:18888 。服务后台运行，关闭终端不影响服务。

```powershell
# 停止服务、执行测试和重新打包，再启动
./start-project.ps1 -Rebuild

# 停止服务
./start-project.ps1 -Stop
```

可通过 `-JavaHome` 和 `-GradleHome` 指定其他安装路径。Windows 会锁住正在运行的 JAR，请先停止服务再打包。

## 配置和日志

也可以直接运行：

```powershell
# 终端交互
java -jar build/libs/mewcode.jar
java -jar build/libs/mewcode.jar -p "请解释当前项目结构"
java -jar build/libs/mewcode.jar --remote
```

## 安全提示

不要提交真实 API Key、会话记录、运行日志或本地配置。发布前请使用 `git grep` 检查密钥，并为已经暴露过的密钥生成新 Key。

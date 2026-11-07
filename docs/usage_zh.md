# 中文使用说明

## 这是什么

一个可以反复使用的 AI 技能包。以后不管要给什么 AI 系统做评测，你只需要**填一份半页纸的 spec**，AI 就会按照你的方法、避开你踩过的坑，参考你 evolutionharness 的代码风格，把 harness 搭出来。

| 文件 | 作用 |
|---|---|
| `skills/build-eval-harness/SKILL.md` | 技能本体：搭建步骤、8 个已知的评测器误判、交付清单 |
| `skills/build-eval-harness/spec_template.md` | 每个新系统要填写的 spec 模板（中英对照，10 个问题） |
| `examples/spec_text_to_sql.md` | 填好的 spec 示例，用来参考每一节写到什么程度 |
| `dist/build-eval-harness.zip` | 打包好的技能，可以直接上传到 claude.ai |
| `docs/spec_template_bilingual.md` | 中英对照版的 spec 模板 |
| `package.sh` | 修改 SKILL.md 之后，用它重新打包 zip |

## 第一步：安装技能（三种方式，选一种）

### 方式 A：claude.ai 网页版（推荐）

你今天在对话里已经点过保存的话，这个技能**已经在你的账号里了**，可以跳过这一步。

需要重新安装或更新时：
1. 下载本仓库的 `dist/build-eval-harness.zip`；
2. 在 claude.ai 进入 **Customize → Skills**，点 **+** → **Create skill** → **Upload a skill**，上传 zip；
3. 打开这个技能的开关。

前提：需要在 **Settings → Capabilities** 里开启代码执行（Code execution / Create and edit files）。参考：[Use skills in Claude](https://support.claude.com/en/articles/12512180-use-skills-in-claude)

### 方式 B：Claude Code

在 claude.ai 里启用过的技能，用同一个账号登录 Claude Code 时会自动同步过来，运行 `/skills` 可以看到。

也可以手动放到本地：把 `skills/build-eval-harness/` 这个文件夹复制到 `~/.claude/skills/`（所有项目可用），或者复制到某个项目的 `.claude/skills/`（只在这个项目里可用）。

### 方式 C：其他 AI（ChatGPT、Copilot 等）

把 `SKILL.md` 的全部内容和你的 spec 一起粘贴到对话里，说："按照这份技能说明，根据下面的 spec 搭建 harness"。

## 第二步：为新系统填写 spec

1. 复制 `skills/build-eval-harness/spec_template.md`，改个名字，比如 `spec_my_system.md`；
2. 对照 `examples/spec_text_to_sql.md`，把 10 节都填上；
3. **第 3 节"怎么自动判断对错"最重要**。想不清楚可以先写 `TBD`，AI 会先跟你讨论这一节，再开始动手。

## 第三步：让 AI 开始搭建

新开一个对话，输入：

> 用 build-eval-harness 这个 skill，按照下面的 spec 搭建一个 harness。
> （粘贴你的 spec，或者上传 spec 文件）

AI 会按以下顺序工作：
1. 检查 spec，缺少的内容一次性问你；
2. 确定判断对错的方法；
3. 建题库、攻击题、mock agent、guardrails；
4. 写批改程序和报告，**先用 mock 验证批改程序没问题**；
5. 用真实模型跑 3 轮，逐条检查失败的题，区分是模型的错还是批改程序的错；
6. （可选）prompt 进化、RAG。

## 第四步：检查交付物

对照 SKILL.md 最后的 **Deliverables checklist** 逐项确认。特别注意两点：
- mock 里故意埋的 bug **全部被抓到了吗**？
- 每道失败的题，**都确认过不是批改程序误判**了吗？

## 更新技能

以后在新项目里又发现了新的坑：
1. 把它加进 `SKILL.md` 的 "Known evaluator false negatives" 那一节；
2. 运行 `./package.sh` 重新打包；
3. 提交到 GitHub，再到 claude.ai 重新上传 zip。

技能会随着你做的项目越来越多而越来越好用。

## 注意事项

- **公司数据只能用公司批准的 AI 服务**（比如公司租户内的 Azure OpenAI）。免费额度的服务和海外服务只用于公开数据或模拟数据。
- 拿到评测结果之后，**不要为了提高分数去修改考题**。发现题目有歧义，记录下来，在下一版题库里修正。

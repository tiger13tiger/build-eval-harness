# Harness Spec — <system name>

> Copy this file, fill every section, and give it to the AI together with the `build-eval-harness` skill.
> 复制本文件，填好每一节，连同 `build-eval-harness` skill 一起交给 AI。
> Leave a section as `TBD` if you don't know yet — the AI will ask about it.

## 1. System / 系统是什么
- What it does / 做什么:
- Who uses it / 谁在用:
- Example inputs → outputs / 输入输出示例:
  - 
  - 

## 2. Interface / 怎么调用
- How to call it (API, function, model + prompt + tools) / 调用方式:
- Tools or actions the AI can take / AI 能用的工具或操作:

## 3. Correctness / 怎么自动判断对错（最重要）
- How an output is judged right or wrong / 判对错的方法:
  (e.g. compare query results, exact field match, numbers within ±0.01, unit tests pass, LLM judge with rubric)
- Source of gold answers / 标准答案从哪里来:

## 4. Should-decline cases / 应该拒绝或反问的情况
- 

## 5. Data access / 数据权限
- Can read / 可以读:
- Can change / 可以改:
- Must never touch / 绝对不能碰（隐私、写操作等）:

## 6. Risks and attacks / 风险和攻击方式
- Direct misuse / 直接滥用:
- Tricks hidden in the data it reads / 藏在数据里的诱导（间接注入）:

## 7. Metrics and thresholds / 指标和上线门槛
| Metric | Go-live threshold |
|---|---|
| Accuracy / task completion | |
| Safety pass rate | 100% |
| Latency p95 | |
| Cost per call | |

## 8. Model and environment / 模型和运行环境
- Allowed providers / 允许用的模型服务:
- Where data may be processed / 数据可以在哪里处理:

## 9. Existing material / 现有材料
- Reports, verified queries, logs, FAQs to mine for test cases / 可用来出题的报表、SQL、日志、FAQ:

## 10. Scope / 范围
- Must have now / 现在必须做:
- Later / 以后再做 (prompt evolution, RAG, monitoring):

# 第一次渲染指南

[English](first-render-walkthrough.md) | 简体中文

这份指南面向第一次使用 `matlab-plotting-skill` 的用户。目标不是马上处理私有数据，而是先用仓库内置示例跑通一条安全路径：查看方案目录、确认 MATLAB CLI、检查数据结构、预览作图选择、渲染 PNG/SVG，并生成一份可复核的反馈草稿。

## 1. 先看元数据

这些命令不需要 MATLAB：

```bash
./scripts/doctor.sh --out /tmp/matlab-plotting-skill-doctor
./scripts/render_with_matlab.sh --list-schemes
./scripts/render_with_matlab.sh --scheme-info line_trend
./scripts/render_with_matlab.sh --scheme-info-json line_trend
```

它们用于确认仓库、scheme catalog 和 shell wrapper 都能正常工作。先跑这一步，可以把“仓库本身不可用”和“MATLAB 路径不可用”分开排查。
doctor 会生成 `first_use_doctor.md/json`，但不会渲染图形。

## 2. 确认 MATLAB CLI

如果 MATLAB 不在 `PATH`，请显式设置 `MATLAB_BIN`：

```bash
export MATLAB_BIN=/Applications/MATLAB_R2025a.app/bin/matlab
./scripts/render_with_matlab.sh --check
```

在 Windows Git Bash 里，通常需要写出 `.exe` 后缀，并给 `Program Files`
路径加引号：

```bash
MATLAB_BIN="/c/Program Files/MATLAB/R2024b/bin/matlab.exe" \
  ./scripts/render_with_matlab.sh --check
```

如果这一步失败，先修 MATLAB 调用路径。元数据命令，例如 `--list-schemes`、`--scheme-info` 和 `--scheme-info-json`，仍然可以继续使用。

MATLAB 相关命令默认有 600 秒超时保护。`--smoke-test` 会根据 catalog 大小自动扩展预算，并在启动 MATLAB 前打印本次预算。只有当你明确要让一次本地长渲染不受这个保护限制时，才使用：

```bash
export MP_MATLAB_TIMEOUT_SECONDS=0
```

## 3. 先检查数据结构

第一次处理某个文件时，先用 `--inspect-data` 看结构：

```bash
./scripts/render_with_matlab.sh --inspect-data --data examples/data/time_series.csv
```

JSON 输出里优先看 `RoleHint` 和 `NextCommandHint`。前者用一句话说明这个数据大概像什么，例如 `looks like a single time series`；后者给出下一步可以尝试的 `--plan-only` 命令。这个提示只使用文件名或 `<data-file>` 占位，不写入完整本地绝对路径。

如果 MAT 文件里有多个变量，请先确认变量名，再用 `--var <name>` 指定。不要在变量含义不清楚时直接渲染。

## 4. 先生成计划，不直接渲染

用 `--plan-only` 查看选中的 scheme、候选方案和评分快照。这个命令不会写图像文件：

```bash
./scripts/render_with_matlab.sh \
  --plan-only \
  --data examples/data/time_series.csv \
  --goal "show a time trend"
```

如果推荐结果不符合你的目标，可以调整 goal 文本，也可以先查看某个明确 scheme 的说明：

```bash
./scripts/render_with_matlab.sh --scheme-info line_trend
```

使用 `--scheme` 会跳过自动规划，适合你已经明确知道要用哪个 renderer 的时候：

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --scheme line_trend \
  --out figures/first-render
```

## 5. 渲染 PNG 和 SVG

确认数据和方案都合理以后，再渲染：

```bash
./scripts/render_with_matlab.sh \
  --data examples/data/time_series.csv \
  --goal "show a time trend" \
  --out figures/first-render \
  --formats png,svg
```

如果你需要论文或报告里的矢量输出，可以使用：

```bash
--formats png,svg,pdf
```

非法格式会在 MATLAB 启动前失败。输出目录通常会包含图像文件，以及：

- `render_report.md`
- `render_report.json`

Markdown 报告适合人工阅读，JSON 报告适合后续自动化处理。

## 6. 分享前先复核

把图用于论文、报告、公开仓库或 issue 反馈前，请先检查：

1. `render_report.md` 里的 selected scheme 和 alternatives 是否符合任务。
2. 坐标轴、图例、单位和标题是否有实际含义。
3. 输出目录里没有私人数据、账号信息、完整本地路径、未公开研究内容或第三方绘图素材。
4. 如果准备把图提交到仓库，先运行：

```bash
./scripts/check_gallery_outputs.sh --dir figures/first-render --format png
./scripts/check_privacy.sh
./scripts/check_forbidden_files.sh
```

## 7. 生成第一次使用反馈

公开反馈入口是：

https://github.com/Kkkakania/matlab-plotting-skill/issues/11

有价值的反馈应尽量具体：操作系统、MATLAB 版本、命令序列、选中的 scheme、`render_report.md` 摘要、预期结果和实际结果。不要上传私有数据文件、未脱敏日志、论文截图、第三方绘图库或完整本地路径。

渲染完成后，可以从输出目录生成一份基础脱敏的 Markdown 草稿：

```bash
./scripts/collect_first_use_feedback.sh \
  --out figures/first-render \
  --doctor /tmp/matlab-plotting-skill-doctor \
  --command './scripts/render_with_matlab.sh --data <redacted> --goal "show a time trend" --out figures/first-render --formats png,svg' \
  --matlab R2025a \
  --os macOS \
  --commit "$(git rev-parse --short HEAD)" \
  --goal "show a time trend" \
  --data-shape "24 rows, 1 time column, 1 value column"
```

提交前仍然要人工复核。这个 helper 会处理常见本地路径和邮件地址形状，但不能替你判断研究内容、实验室信息、账号名或第三方材料是否适合公开。
`--data-shape` 只写 `--inspect-data` 得到的结构摘要，例如行数、列数和角色提示；不要把私有数据行直接贴进反馈。

复制反馈时可以使用这个结构：

```text
OS:
MATLAB:
Commit:
Command sequence:
first_use_doctor.md/json summary:
Data shape:
Goal text:
Selected scheme:
Top alternatives:
Output formats:
render_report.md summary:
Expected result:
Actual result:
Private details redacted: yes/no
```

## 常见第一选择

| 目标 | 建议先试 |
|---|---|
| 展示一个随时间或顺序变化的量 | `line_trend` |
| 比较多条有顺序的曲线 | `multi_line_comparison` |
| 展示中心线和不确定性范围 | `confidence_band` |
| 在长趋势里突出局部事件 | `zoomed_inset_line` |
| 展示两个数值变量的关系 | `scatter_relationship` |
| 展示分组 x-y 观测 | `grouped_scatter` |
| 展示大量重叠散点 | `density_scatter` |
| 比较类别分数 | `grouped_bar` |
| 展示数值矩阵 | `heatmap_matrix` |

更完整的选择说明见 [`docs/chart-selection-guide.md`](chart-selection-guide.md)。

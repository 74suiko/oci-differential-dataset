#!/bin/bash
# runc-4014 Differential Testing Reproduction Script
# 目标: 验证当 pids limit 设置为 0 时，不同运行时的 Cgroup 解析差异

echo "=========================================================="
echo "🎯 正在复现 Issue 4014: Pids Limit = 0 的模糊语义解析差异"
echo "=========================================================="

CRUN_BIN="/usr/bin/crun"
# 注意：这里使用你系统上现有的 runc 即可，因为这个 no-op 特性在 runc 中存在了很久
RUNC_BIN=$(which runc) 

# 1. 使用 Python 动态注入恶意 Payload
# 强行设置 pids.limit = 0，并让容器启动时直接打印内核的 pids.max
python3 -c '
import json, os
if not os.path.exists("config.json"):
    print("错误: 找不到 config.json")
    exit(1)
with open("config.json", "r") as f: d = json.load(f)

# 注入 pids limit = 0
if "linux" not in d: d["linux"] = {}
if "resources" not in d["linux"]: d["linux"]["resources"] = {}
d["linux"]["resources"]["pids"] = {"limit": 0}

# 修改启动命令，探查 cgroup v1 或 v2 的真实限制值
d["process"]["args"] = ["/bin/sh", "-c", "cat /sys/fs/cgroup/pids.max 2>/dev/null || cat /sys/fs/cgroup/pids/pids.max 2>/dev/null"]
d["process"]["terminal"] = False

with open("config.json", "w") as f: json.dump(d, f, indent=4)
'

echo -e "\n[对照组] 正在使用 crun 运行 (预期输出 max)..."
# crun 会把 0 解释为“无限制”
sudo $CRUN_BIN run test-4014-crun

echo -e "\n[实验组] 正在使用 runc 运行 (预期输出继承的父级数字，而不是 max)..."
# runc 会把 0 视为“忽略/未设置 (no-op)”
sudo $RUNC_BIN run test-4014-runc

echo "=========================================================="
echo "🧹 现场无需额外清理，容器执行 cat 后已自动退出。"
echo "测试结束。"
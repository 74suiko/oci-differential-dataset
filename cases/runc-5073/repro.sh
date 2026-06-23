#!/bin/bash
# 目标: 验证 Cgroup eBPF 设备过滤规则是否错误地放行了 mknod 操作

echo "=========================================================="
echo "🎯 正在复现 Issue 5073: mknod 权限被无条件授予的漏洞"
echo "=========================================================="

# 1. 动态注入 Cgroup 设备限制，仅允许对 12:42 设备有 "r" (读) 权限
python3 -c '
import json, os
if not os.path.exists("config.json"):
    print("未找到 config.json，请先执行 runc spec 生成")
    exit(1)
with open("config.json", "r") as f: d = json.load(f)

if "linux" not in d: d["linux"] = {}
if "resources" not in d["linux"]: d["linux"]["resources"] = {}
# 仅授权特定设备的读取权限
d["linux"]["resources"]["devices"] = [
    {"allow": True, "type": "c", "major": 12, "minor": 42, "access": "r"}
]

# 核心测试命令：尝试 mknod 创建一个未被授权的设备节点 (42:42)
d["process"]["args"] = [
    "/bin/sh", 
    "-c", 
    "mknod /dev/mytest2 c 42 42 && echo \"[🚨 漏洞存在] mknod 越权执行成功！\" || echo \"[✅ 表现正常] mknod 被 eBPF 成功拦截！\""
]
d["process"]["terminal"] = False

with open("config.json", "w") as f: json.dump(d, f, indent=4)
'

echo -e "\n[对照组] 正在使用 crun 运行 (预期行为: 拦截 mknod)..."
sudo /usr/bin/crun run test-5073-crun

echo -e "\n[实验组] 正在使用 runc-buggy 运行 (异常行为: 允许 mknod)..."
# 请确保你的 oci-lab/bin 目录下有对应老版本的 runc
sudo ~/oci-lab/bin/runc-buggy-5073 run test-5073-runc

echo "=========================================================="
echo "测试结束。"
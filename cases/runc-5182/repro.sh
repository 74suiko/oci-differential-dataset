#!/bin/bash
# runc-5182 Differential Testing Reproduction Script
# Author: Suiko (OCI Differential Dataset)

echo "=========================================================="
echo "🎯 正在复现 Issue 5182: OCI 运行时 Hook 生命周期差分测试"
echo "=========================================================="

BUNDLE_DIR="."
CRUN_BIN="/usr/bin/crun"
RUNC_BUGGY_BIN="$HOME/oci-lab/bin/runc-buggy-5182"

# 准备包含恶意 Hook 的配置
cp buggy_config.json config.json

echo -e "\n[对照组] 正在使用标准运行时 crun 进行测试..."
sudo rm -f /tmp/post-start /tmp/post-stop
sudo $CRUN_BIN delete -f test-crun 2>/dev/null
sudo $CRUN_BIN create test-crun
sudo $CRUN_BIN start test-crun 2>/dev/null  # 预期在此处报错
sudo $CRUN_BIN delete -f test-crun 2>/dev/null

if [ -f "/tmp/post-stop" ]; then
    echo "✅ crun 表现正确: poststop 钩子成功执行，资源已被回收。"
else
    echo "❌ crun 表现异常。"
fi

echo -e "\n[实验组] 正在使用带漏洞的 runc-buggy 进行测试..."
sudo rm -f /tmp/post-start /tmp/post-stop
sudo $RUNC_BUGGY_BIN delete -f test-buggy 2>/dev/null
sudo $RUNC_BUGGY_BIN create test-buggy 2>/dev/null # 预期在此处抢先报错
sudo $RUNC_BUGGY_BIN delete -f test-buggy 2>/dev/null

if [ ! -f "/tmp/post-stop" ]; then
    echo "🚨 成功捕获漏洞! runc-buggy 未执行 poststop 钩子，引发资源泄露！"
else
    echo "❓ 未能捕获漏洞，post-stop 文件存在。"
fi

echo "=========================================================="
echo "🧹 清理现场..."
rm -f config.json
sudo rm -f /tmp/post-start /tmp/post-stop
echo "测试结束。"
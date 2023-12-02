#!/bin/bash

# 检查是否以 root 用户身份运行脚本
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 用户身份运行该脚本。"
   exit 1
fi

# 检查是否提供了域名参数
if [ -z "$1" ]; then
   echo "请提供域名作为第一个参数。"
   exit 1
fi

# 检查是否提供了密码参数
if [ -z "$2" ]; then
   echo "请自定义trojan密码作为第二个参数。"
   exit 1
fi

# 安装 Nginx Unzip等工具
apt-get update
apt-get install -y nginx unzip wget

# 创建 Nginx 配置文件
cat > "/etc/nginx/sites-available/$1" <<EOF
server {
    listen 80;
    server_name $1;

    root /var/www/html;
    index index.html index.nginx-debian.html;
}
EOF

# 创建符号链接以启用站点
ln -s "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"

# 重新加载 Nginx 配置
systemctl reload nginx

echo "Nginx 安装并配置完成。"

echo "安装trojan-go"

wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip
cp trojan-go /usr/local/bin/trojan-go
chmod +x /usr/local/bin/trojan-go

# 创建 trojan-go 配置文件
mkdir /etc/trojan-go
cat > "/etc/trojan-go/config.yaml" <<EOF
run-type: server
local-addr: 0.0.0.0
local-port: 443
remote-addr: 127.0.0.1
remote-port: 80
password:
  - $2
ssl:
  cert: /etc/trojan-go/server.crt
  key: /etc/trojan-go/server.key
EOF

cat > "/lib/systemd/system/trojan-go.service" <<EOF
Description=trojan
After=network.target nginx.service
Requires=nginx.service

[Service]
Type=simple
ExecStartPre=/bin/sleep 5
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.yaml

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable trojan-go

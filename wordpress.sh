#!/bin/bash
# 定义容器项目目录（与脚本同级）
PROJECT_DIR="$(dirname "$0")"

# 颜色定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # 清除颜色

# 检查 docker compose 可用性
check_docker_compose() {
  if ! docker compose version &>/dev/null; then
    echo -e "${RED}错误：需要 Docker Compose V2 及以上版本！${NC}"
    echo -e "请通过以下方式安装："
    echo -e "1. Docker Desktop 内置版本（推荐）"
    echo -e "2. 手动安装: ${GREEN}https://docs.docker.com/compose/install/linux/${NC}"
    exit 1
  fi
}

# 检查必要文件
check_environment() {
  if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    echo -e "${RED}错误：未找到 docker-compose.yml 文件！${NC}"
    echo -e "请执行以下命令获取："
    echo -e "${GREEN}curl -O https://raw.githubusercontent.com/multuslove/wordpress_cn/main/docker-compose.yml${NC}"
    exit 1
  fi
}

# 显示服务状态
show_status() {
  echo -e "\n${BLUE}=== 当前容器状态 ===${NC}"
  docker compose -f "$PROJECT_DIR/docker-compose.yml" ps
}

# 启动服务
start_service() {
  echo -e "\n${GREEN}▶ 正在启动服务...${NC}"
  docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d --wait
  show_status
}

# 停止服务
stop_service() {
  echo -e "\n${RED}■ 正在停止服务...${NC}"
  docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  show_status
}

# 重启服务
restart_service() {
  stop_service
  start_service
}

# 查看日志
show_logs() {
  echo -e "\n${YELLOW}▼ 显示实时日志（Ctrl+C 退出）${NC}"
  docker compose -f "$PROJECT_DIR/docker-compose.yml" logs -f --tail=20
}

# 交互菜单
show_menu() {
  clear
  echo -e "${BLUE}=============================="
  echo -e " WordPress 容器管理脚本 "
  echo -e "==============================${NC}"
  echo -e "[1] 启动服务"
  echo -e "[2] 停止服务"
  echo -e "[3] 重启服务"
  echo -e "[4] 查看状态"
  echo -e "[5] 查看日志"
  echo -e "[6] 打开浏览器"
  echo -e "[0] 退出脚本"
  echo -e "${BLUE}==============================${NC}"
}

# 获取容器端口
get_port() {
  local port=$(grep -oP 'WORDPRESS_PORT=\K\d+' "$PROJECT_DIR/.env" 2>/dev/null)
  [ -z "$port" ] && 
    port=$(grep -oP 'published:\s+\K\d+' "$PROJECT_DIR/docker-compose.yml" | head -1)
  echo "${port:-80}"
}

# 主程序
check_docker_compose
check_environment
while true; do
  show_menu
  show_status
  echo -en "\n请输入操作编号: "
  read -r choice
  case $choice in
    1) start_service ;;
    2) stop_service ;;
    3) restart_service ;;
    4) show_status ;;
    5) show_logs ;;
    6)
      port=$(get_port)
      xdg-open "http://localhost:$port" 2>/dev/null || \
        echo -e "${YELLOW}请在浏览器访问: http://localhost:$port${NC}"
      ;;
    0)
      echo -e "\n${GREEN}脚本已退出${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}无效选项，请重新输入！${NC}"
      ;;
  esac
  echo -en "\n按回车键继续..."
  read -r
done

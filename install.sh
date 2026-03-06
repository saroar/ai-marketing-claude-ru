#!/bin/bash
# AI Marketing Suite RU — Установщик скилов Claude Code
# Устанавливает маркетинговые скилы для русского рынка
# Команда: /market-ru (не конфликтует с английской версией /market)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  AI Marketing Suite RU — для Русского рынка  ║${NC}"
echo -e "${CYAN}║  Яндекс · VK · Telegram · 152-ФЗ · Метрика  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Detect script directory
if [ -n "$BASH_SOURCE" ] && [ "$BASH_SOURCE" != "bash" ] && [ -f "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
else
    echo -e "${RED}Запустите install.sh из папки репозитория.${NC}"
    exit 1
fi

# Target directories — use "market-ru" prefix to coexist with English version
SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

echo -e "${BLUE}Источник:${NC}  $SCRIPT_DIR"
echo -e "${BLUE}Цель:${NC}      $SKILLS_DIR"
echo ""

# Check if Claude Code is available
if command -v claude &>/dev/null; then
    echo -e "${GREEN}✓ Claude Code обнаружен${NC}"
else
    echo -e "${YELLOW}⚠ Claude Code не найден в PATH${NC}"
    if [ -t 0 ]; then
        read -p "  Продолжить? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Установка отменена."
            exit 0
        fi
    else
        echo "  Продолжаю (неинтерактивный режим)..."
    fi
fi

# Create directories
echo -e "\n${BLUE}Создание директорий...${NC}"
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Install main skill orchestrator as "market-ru"
echo -e "${BLUE}Установка главного скила (market-ru)...${NC}"
mkdir -p "$SKILLS_DIR/market-ru"
cp "$SCRIPT_DIR/market/SKILL.md" "$SKILLS_DIR/market-ru/SKILL.md"
echo -e "  ${GREEN}✓${NC} market-ru/SKILL.md (оркестратор)"

# Install sub-skills with "market-ru-" prefix
echo -e "\n${BLUE}Установка под-скилов...${NC}"
SKILLS=(
    "market-audit"
    "market-copy"
    "market-emails"
    "market-social"
    "market-ads"
    "market-funnel"
    "market-competitors"
    "market-landing"
    "market-launch"
    "market-proposal"
    "market-report"
    "market-report-pdf"
    "market-seo"
    "market-brand"
)

SKILL_COUNT=0
for skill in "${SKILLS[@]}"; do
    ru_skill="${skill/market-/market-ru-}"
    if [ -f "$SCRIPT_DIR/skills/$skill/SKILL.md" ]; then
        mkdir -p "$SKILLS_DIR/$ru_skill"
        cp "$SCRIPT_DIR/skills/$skill/SKILL.md" "$SKILLS_DIR/$ru_skill/SKILL.md"
        echo -e "  ${GREEN}✓${NC} $ru_skill"
        SKILL_COUNT=$((SKILL_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $skill (не найден, пропуск)"
    fi
done

# Install agents with "market-ru-" prefix
echo -e "\n${BLUE}Установка агентов...${NC}"
AGENTS=(
    "market-content"
    "market-conversion"
    "market-competitive"
    "market-technical"
    "market-strategy"
)

AGENT_COUNT=0
for agent in "${AGENTS[@]}"; do
    ru_agent="${agent/market-/market-ru-}"
    if [ -f "$SCRIPT_DIR/agents/$agent.md" ]; then
        cp "$SCRIPT_DIR/agents/$agent.md" "$AGENTS_DIR/$ru_agent.md"
        echo -e "  ${GREEN}✓${NC} $ru_agent"
        AGENT_COUNT=$((AGENT_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $agent (не найден, пропуск)"
    fi
done

# Install scripts (shared scripts dir under market-ru)
echo -e "\n${BLUE}Установка скриптов...${NC}"
SCRIPTS_TARGET="$SKILLS_DIR/market-ru/scripts"
mkdir -p "$SCRIPTS_TARGET"

SCRIPT_FILES=(
    "analyze_page.py"
    "competitor_scanner.py"
    "social_calendar.py"
    "generate_pdf_report.py"
)

SCRIPT_COUNT=0
for script in "${SCRIPT_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/scripts/$script" ]; then
        cp "$SCRIPT_DIR/scripts/$script" "$SCRIPTS_TARGET/$script"
        chmod +x "$SCRIPTS_TARGET/$script"
        echo -e "  ${GREEN}✓${NC} $script"
        SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
    else
        echo -e "  ${YELLOW}⚠${NC} $script (не найден, пропуск)"
    fi
done

# Install templates
echo -e "\n${BLUE}Установка шаблонов...${NC}"
TEMPLATES_TARGET="$SKILLS_DIR/market-ru/templates"
mkdir -p "$TEMPLATES_TARGET"

TEMPLATE_COUNT=0
if [ -d "$SCRIPT_DIR/templates" ]; then
    for template in "$SCRIPT_DIR/templates"/*.md; do
        if [ -f "$template" ]; then
            cp "$template" "$TEMPLATES_TARGET/$(basename "$template")"
            echo -e "  ${GREEN}✓${NC} $(basename "$template")"
            TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
        fi
    done
fi

# Install Python dependencies
echo -e "\n${BLUE}Проверка зависимостей Python...${NC}"
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    echo -e "  ${GREEN}✓${NC} Python $PYTHON_VERSION обнаружен"

    if python3 -c "import reportlab" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} reportlab установлен (PDF-отчёты готовы)"
    else
        echo -e "  ${YELLOW}⚠${NC} reportlab не установлен (нужен для PDF)"
        echo -e "    Установить: ${CYAN}pip install reportlab${NC}"
    fi

    if python3 -c "import requests" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} requests установлен"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Python 3 не найден — скрипты не будут работать"
fi

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Установка завершена!                   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Скилов установлено:   ${GREEN}$SKILL_COUNT${NC}"
echo -e "  Агентов установлено:  ${GREEN}$AGENT_COUNT${NC}"
echo -e "  Скриптов установлено: ${GREEN}$SCRIPT_COUNT${NC}"
echo -e "  Шаблонов установлено: ${GREEN}$TEMPLATE_COUNT${NC}"
echo ""
echo -e "${CYAN}Доступные команды (/market-ru):${NC}"
echo "  /market-ru audit <url>        Полный аудит (5 параллельных агентов)"
echo "  /market-ru quick <url>        Быстрый снапшот за 60 секунд"
echo "  /market-ru copy <url>         Генерация копирайтинга"
echo "  /market-ru emails <тема>      Email-последовательности"
echo "  /market-ru social <тема>      Контент-план (ВК, Telegram, OK.ru)"
echo "  /market-ru ads <url>          Яндекс.Директ + VK Ads + Telegram"
echo "  /market-ru funnel <url>       Анализ воронки продаж"
echo "  /market-ru competitors <url>  Конкурентная разведка"
echo "  /market-ru landing <url>      CRO-анализ лендинга"
echo "  /market-ru launch <продукт>   План запуска"
echo "  /market-ru proposal <клиент>  Коммерческое предложение"
echo "  /market-ru report <url>       Маркетинговый отчёт"
echo "  /market-ru seo <url>          SEO-аудит (Яндекс + Google)"
echo "  /market-ru brand <url>        Анализ голоса бренда"
echo ""
echo -e "  ${YELLOW}Начните новую сессию Claude Code для использования скилов.${NC}"
echo -e "  ${GREEN}Оба варианта (/market и /market-ru) работают одновременно.${NC}"
echo ""

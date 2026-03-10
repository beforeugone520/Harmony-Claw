#!/usr/bin/env python3
"""
记账工具 - 读取统计数据
"""

import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any


def get_data_path() -> Path:
    """获取数据文件路径"""
    home = Path.home()
    return home / ".openclaw" / "data" / "accounting.json"


def load_data() -> dict:
    """加载现有数据"""
    data_path = get_data_path()
    if data_path.exists():
        with open(data_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {
        "version": "1.0",
        "updatedAt": int(datetime.now().timestamp() * 1000),
        "bills": [],
        "dailyStats": [],
        "monthlyStats": []
    }


def get_stats(params: dict[str, Any]) -> dict[str, Any]:
    """
    获取统计数据

    Args:
        params: 包含 period 参数的字典 (week/month/year)

    Returns:
        包含日统计和月统计的字典
    """
    data = load_data()
    period = params.get("period", "month")

    today = datetime.now()

    if period == "week":
        # Get last 7 days
        start_date = today - timedelta(days=7)
        daily = [s for s in data["dailyStats"]
                 if datetime.strptime(s["date"], "%Y-%m-%d") >= start_date]
    elif period == "month":
        # Get current month
        current_month = today.strftime("%Y-%m")
        daily = [s for s in data["dailyStats"] if s["date"].startswith(current_month)]
    else:  # year
        current_year = today.strftime("%Y")
        daily = [s for s in data["dailyStats"] if s["date"].startswith(current_year)]

    return {
        "success": True,
        "data": {
            "daily": daily,
            "monthly": data["monthlyStats"]
        }
    }


if __name__ == "__main__":
    params = json.load(sys.stdin)
    result = get_stats(params)
    print(json.dumps(result, ensure_ascii=False))

#!/usr/bin/env python3
"""
日程工具 - 读取日程记录
"""

import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any


def get_data_path() -> Path:
    """获取数据文件路径"""
    home = Path.home()
    return home / ".openclaw" / "data" / "schedule.json"


def load_data() -> dict:
    """加载现有数据"""
    data_path = get_data_path()
    if data_path.exists():
        with open(data_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {
        "version": "1.0",
        "updatedAt": int(datetime.now().timestamp() * 1000),
        "events": [],
        "categories": ["工作", "个人", "健康", "学习", "社交", "娱乐"]
    }


def read_events(params: dict[str, Any]) -> dict[str, Any]:
    """
    读取日程列表

    Args:
        params: 包含筛选参数的字典

    Returns:
        包含日程列表的字典
    """
    data = load_data()
    events = data["events"]

    date_str = params.get("date")
    include_past = params.get("includePast", False)

    now = datetime.now()

    if date_str:
        # Filter by specific date
        target_date = datetime.strptime(date_str, "%Y-%m-%d")
        start_of_day = target_date.replace(hour=0, minute=0, second=0, microsecond=0)
        end_of_day = start_of_day + timedelta(days=1)

        events = [
            e for e in events
            if start_of_day.timestamp() * 1000 <= e["startTime"] < end_of_day.timestamp() * 1000
        ]
    elif not include_past:
        # Filter out past events
        events = [e for e in events if e["startTime"] >= now.timestamp() * 1000]

    # Sort by start time
    events.sort(key=lambda x: x["startTime"])

    return {
        "success": True,
        "data": {
            "events": events,
            "categories": data["categories"]
        }
    }


if __name__ == "__main__":
    params = json.load(sys.stdin)
    result = read_events(params)
    print(json.dumps(result, ensure_ascii=False))

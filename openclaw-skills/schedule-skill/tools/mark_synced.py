#!/usr/bin/env python3
"""
日程工具 - 标记日程已同步
"""

import json
import sys
from datetime import datetime
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


def save_data(data: dict) -> None:
    """保存数据"""
    data_path = get_data_path()
    data["updatedAt"] = int(datetime.now().timestamp() * 1000)
    with open(data_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def mark_synced(params: dict[str, Any]) -> dict[str, Any]:
    """
    标记日程已同步到系统日历

    Args:
        params: 包含 eventId 的字典

    Returns:
        同步结果字典
    """
    data = load_data()
    event_id = params["eventId"]

    event = next((e for e in data["events"] if e["id"] == event_id), None)
    if not event:
        return {
            "success": False,
            "error": f"Event not found: {event_id}"
        }

    event["syncedToCalendar"] = True
    save_data(data)

    return {
        "success": True,
        "eventId": event_id,
        "message": f"Event '{event['title']}' marked as synced"
    }


if __name__ == "__main__":
    params = json.load(sys.stdin)
    result = mark_synced(params)
    print(json.dumps(result, ensure_ascii=False))

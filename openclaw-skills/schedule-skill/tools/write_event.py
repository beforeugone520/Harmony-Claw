#!/usr/bin/env python3
"""
日程工具 - 写入日程记录
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


def get_data_path() -> Path:
    """获取数据文件路径"""
    home = Path.home()
    data_dir = home / ".openclaw" / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    return data_dir / "schedule.json"


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


def write_event(params: dict[str, Any]) -> dict[str, Any]:
    """
    写入日程记录

    Args:
        params: 包含日程信息的字典

    Returns:
        包含新创建日程信息的字典
    """
    data = load_data()

    # Generate unique ID
    event_id = f"event_{len(data['events']) + 1:03d}_{int(datetime.now().timestamp())}"

    event = {
        "id": event_id,
        "title": params["title"],
        "description": params.get("description", ""),
        "startTime": params["startTime"],
        "endTime": params["endTime"],
        "location": params.get("location", ""),
        "category": params.get("category", "个人"),
        "isAllDay": params.get("isAllDay", False),
        "recurrence": params.get("recurrence", None),
        "reminder": params.get("reminder", 15),
        "syncedToCalendar": False,
        "createdAt": int(datetime.now().timestamp() * 1000)
    }

    data["events"].append(event)
    save_data(data)

    # Format time for response
    start_dt = datetime.fromtimestamp(params["startTime"] / 1000)
    time_str = start_dt.strftime("%Y-%m-%d %H:%M")

    return {
        "success": True,
        "data": event,
        "message": f"已添加日程：{event['title']} ({time_str})"
    }


if __name__ == "__main__":
    params = json.load(sys.stdin)
    result = write_event(params)
    print(json.dumps(result, ensure_ascii=False))

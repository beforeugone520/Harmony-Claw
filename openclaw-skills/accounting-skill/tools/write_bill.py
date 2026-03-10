#!/usr/bin/env python3
"""
记账工具 - 写入账单记录
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
    return data_dir / "accounting.json"


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


def save_data(data: dict) -> None:
    """保存数据"""
    data_path = get_data_path()
    data["updatedAt"] = int(datetime.now().timestamp() * 1000)
    with open(data_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def update_daily_stats(data: dict, date: str, amount: float, calories: int) -> None:
    """更新日统计"""
    daily_stat = next((s for s in data["dailyStats"] if s["date"] == date), None)
    if daily_stat:
        daily_stat["totalAmount"] += amount
        daily_stat["totalCalories"] += calories
        if calories > 0:
            daily_stat["mealCount"] += 1
    else:
        data["dailyStats"].append({
            "date": date,
            "totalAmount": amount,
            "totalCalories": calories,
            "mealCount": 1 if calories > 0 else 0
        })


def update_monthly_stats(data: dict, date: str, amount: float, calories: int) -> None:
    """更新月统计"""
    year_month = date[:7]  # YYYY-MM
    monthly_stat = next((s for s in data["monthlyStats"] if s["yearMonth"] == year_month), None)

    if monthly_stat:
        monthly_stat["totalAmount"] += amount
        monthly_stat["totalCalories"] += calories
        # Recalculate average
        days_with_data = len([s for s in data["dailyStats"] if s["date"].startswith(year_month)])
        if days_with_data > 0:
            monthly_stat["avgDailyCalories"] = monthly_stat["totalCalories"] // days_with_data
    else:
        data["monthlyStats"].append({
            "yearMonth": year_month,
            "totalAmount": amount,
            "totalCalories": calories,
            "avgDailyCalories": calories
        })


def write_bill(params: dict[str, Any]) -> dict[str, Any]:
    """
    写入账单记录

    Args:
        params: 包含账单信息的字典

    Returns:
        包含新创建账单信息的字典
    """
    data = load_data()

    # Generate unique ID
    bill_id = f"bill_{len(data['bills']) + 1:03d}_{int(datetime.now().timestamp())}"

    bill = {
        "id": bill_id,
        "date": params["date"],
        "category": params["category"],
        "amount": params["amount"],
        "currency": params.get("currency", "CNY"),
        "items": params.get("items", []),
        "calories": params.get("calories", 0),
        "note": params.get("note", ""),
        "createdAt": int(datetime.now().timestamp() * 1000)
    }

    data["bills"].append(bill)

    # Update statistics
    update_daily_stats(data, params["date"], params["amount"], params.get("calories", 0))
    update_monthly_stats(data, params["date"], params["amount"], params.get("calories", 0))

    save_data(data)

    return {
        "success": True,
        "data": bill,
        "message": f"已记录{bill['category']} {bill['amount']}{bill['currency']}"
    }


if __name__ == "__main__":
    # Read params from stdin (JSON format)
    params = json.load(sys.stdin)
    result = write_bill(params)
    print(json.dumps(result, ensure_ascii=False))

export class DateUtils {
  static formatDate(timestamp: number): string {
    if (!timestamp || isNaN(timestamp)) return '未知';
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return '未知';
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static formatTime(timestamp: number): string {
    if (!timestamp || isNaN(timestamp)) return '';
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return '';
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  static formatDateTime(timestamp: number): string {
    if (!timestamp || isNaN(timestamp)) return '未知';
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return '未知';
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  static formatRelativeTime(timestamp: number): string {
    if (!timestamp || isNaN(timestamp)) return '未知';
    const now = Date.now();
    const diff = now - timestamp;
    if (isNaN(diff)) return '未知';
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (seconds < 60) {
      return '刚刚';
    } else if (minutes < 60) {
      return `${minutes}分钟前`;
    } else if (hours < 24) {
      return `${hours}小时前`;
    } else if (days < 7) {
      return `${days}天前`;
    } else {
      return DateUtils.formatDate(timestamp);
    }
  }

  static getCurrentTimestamp(): number {
    return Date.now();
  }
}

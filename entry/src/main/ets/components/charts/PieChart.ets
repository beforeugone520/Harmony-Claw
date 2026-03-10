/**
 * Pie Chart Component
 * 饼图组件 - 用于展示支出分类占比
 */

import { ExpenseByCategory } from '../../models/AccountingModels';

@Component
export struct PieChart {
  @Prop data: ExpenseByCategory[] = [];
  @Prop title: string = '';
  @Prop showLegend: boolean = true;

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  );

  private drawPieChart(canvasContext: CanvasRenderingContext2D): void {
    if (this.data.length === 0) return;

    const canvasWidth = 280;
    const canvasHeight = this.showLegend ? 240 : 200;
    const centerX = canvasWidth / 2;
    const centerY = this.showLegend ? 90 : 100;
    const radius = 70;

    // Clear canvas
    canvasContext.clearRect(0, 0, canvasWidth, canvasHeight);

    const total = this.data.reduce((sum, item) => sum + item.amount, 0);
    let currentAngle = -Math.PI / 2; // Start from top

    // Draw pie slices
    this.data.forEach(item => {
      const sliceAngle = (item.amount / total) * 2 * Math.PI;

      // Draw slice
      canvasContext.fillStyle = item.color;
      canvasContext.beginPath();
      canvasContext.moveTo(centerX, centerY);
      canvasContext.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle);
      canvasContext.closePath();
      canvasContext.fill();

      // Draw white border
      canvasContext.strokeStyle = '#FFF';
      canvasContext.lineWidth = 2;
      canvasContext.stroke();

      currentAngle += sliceAngle;
    });

    // Draw center hole (donut chart style)
    canvasContext.fillStyle = '#FAFAFA';
    canvasContext.beginPath();
    canvasContext.arc(centerX, centerY, radius * 0.5, 0, 2 * Math.PI);
    canvasContext.fill();

    // Draw center text
    canvasContext.fillStyle = '#333';
    canvasContext.font = 'bold 14px sans-serif';
    canvasContext.textAlign = 'center';
    canvasContext.fillText('¥' + total.toFixed(0), centerX, centerY - 5);

    canvasContext.fillStyle = '#999';
    canvasContext.font = '10px sans-serif';
    canvasContext.fillText('总计', centerX, centerY + 12);

    // Draw legend
    if (this.showLegend) {
      const legendY = 180;
      const itemWidth = canvasWidth / Math.min(this.data.length, 4);

      this.data.slice(0, 4).forEach((item, index) => {
        const x = (index % 4) * itemWidth + itemWidth / 2;
        const y = legendY + Math.floor(index / 4) * 30;

        // Color box
        canvasContext.fillStyle = item.color;
        canvasContext.fillRect(x - 30, y - 6, 10, 10);

        // Label
        canvasContext.fillStyle = '#666';
        canvasContext.font = '10px sans-serif';
        canvasContext.textAlign = 'left';
        canvasContext.fillText(item.category, x - 16, y + 2);

        // Percentage
        canvasContext.fillStyle = '#999';
        canvasContext.font = '9px sans-serif';
        canvasContext.fillText(item.percentage.toFixed(1) + '%', x - 16, y + 14);
      });
    }
  }

  build() {
    Column({ space: 8 }) {
      if (this.title) {
        Text(this.title)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      }

      Canvas(this.context)
        .width('100%')
        .height(this.showLegend ? 240 : 200)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onReady(() => {
          this.drawPieChart(this.context);
        })
        .onAreaChange(() => {
          this.drawPieChart(this.context);
        })
    }
    .width('100%')
  }
}

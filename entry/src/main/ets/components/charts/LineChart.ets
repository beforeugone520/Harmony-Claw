/**
 * Line Chart Component
 * 折线图组件 - 用于展示热量趋势等
 */

import { CalorieTrend } from '../../models/AccountingModels';

@Component
export struct LineChart {
  @Prop data: CalorieTrend[] = [];
  @Prop title: string = '';
  @Prop lineColor: ResourceColor = $r('app.color.brand_primary');
  @Prop targetColor: ResourceColor = '#FF6B6B';
  @Prop showTarget: boolean = true;

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  );

  private canvasWidth: number = 300;
  private canvasHeight: number = 200;
  private paddingTop: number = 20;
  private paddingRight: number = 20;
  private paddingBottom: number = 30;
  private paddingLeft: number = 40;

  private drawLineChart(canvasContext: CanvasRenderingContext2D): void {
    if (this.data.length === 0) return;

    const chartWidth = this.canvasWidth - this.paddingLeft - this.paddingRight;
    const chartHeight = this.canvasHeight - this.paddingTop - this.paddingBottom;

    canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    const maxValue = Math.max(
      ...this.data.map(d => Math.max(d.calories, d.target)),
      1
    );

    canvasContext.strokeStyle = '#E0E0E0';
    canvasContext.lineWidth = 1;

    for (let i = 0; i <= 5; i++) {
      const y = this.paddingTop + (chartHeight / 5) * i;
      canvasContext.beginPath();
      canvasContext.moveTo(this.paddingLeft, y);
      canvasContext.lineTo(this.paddingLeft + chartWidth, y);
      canvasContext.stroke();

      canvasContext.fillStyle = '#999';
      canvasContext.font = '10px sans-serif';
      canvasContext.textAlign = 'right';
      const value = Math.round(maxValue * (5 - i) / 5);
      canvasContext.fillText(value.toString(), this.paddingLeft - 5, y + 3);
    }

    if (this.showTarget && this.data.length > 0) {
      const targetY = this.paddingTop + chartHeight * (1 - this.data[0].target / maxValue);
      canvasContext.strokeStyle = this.targetColor as string;
      canvasContext.setLineDash([5, 5]);
      canvasContext.lineWidth = 1.5;
      canvasContext.beginPath();
      canvasContext.moveTo(this.paddingLeft, targetY);
      canvasContext.lineTo(this.paddingLeft + chartWidth, targetY);
      canvasContext.stroke();
      canvasContext.setLineDash([]);
    }

    if (this.data.length > 1) {
      canvasContext.strokeStyle = this.lineColor as string;
      canvasContext.lineWidth = 2;
      canvasContext.beginPath();

      this.data.forEach((point, index) => {
        const x = this.paddingLeft + (chartWidth / (this.data.length - 1)) * index;
        const y = this.paddingTop + chartHeight * (1 - point.calories / maxValue);

        if (index === 0) {
          canvasContext.moveTo(x, y);
        } else {
          canvasContext.lineTo(x, y);
        }
      });

      canvasContext.stroke();

      this.data.forEach((point, index) => {
        const x = this.paddingLeft + (chartWidth / (this.data.length - 1)) * index;
        const y = this.paddingTop + chartHeight * (1 - point.calories / maxValue);

        canvasContext.fillStyle = '#FFF';
        canvasContext.beginPath();
        canvasContext.arc(x, y, 4, 0, 2 * Math.PI);
        canvasContext.fill();

        canvasContext.fillStyle = this.lineColor as string;
        canvasContext.beginPath();
        canvasContext.arc(x, y, 3, 0, 2 * Math.PI);
        canvasContext.fill();
      });
    }

    canvasContext.fillStyle = '#999';
    canvasContext.font = '9px sans-serif';
    canvasContext.textAlign = 'center';

    const labelIndices = [0, Math.floor(this.data.length / 2), this.data.length - 1];
    labelIndices.forEach(index => {
      if (index >= 0 && index < this.data.length) {
        const x = this.paddingLeft + (chartWidth / (this.data.length - 1)) * index;
        const date = this.data[index].date;
        const label = date.substring(5);
        canvasContext.fillText(label, x, this.canvasHeight - 10);
      }
    });
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
        .height(200)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onReady(() => {
          this.drawLineChart(this.context);
        })
        .onAreaChange(() => {
          this.drawLineChart(this.context);
        })
    }
    .width('100%')
  }
}

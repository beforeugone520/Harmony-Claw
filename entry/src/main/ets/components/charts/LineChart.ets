/**
 * Line Chart Component - Optimized
 * 折线图组件 - 优化版
 */

import { CalorieTrend } from '../../models/AccountingModels'
import { DesignTokens as DT } from '../../constants/DesignTokens'

interface Point {
  x: number
  y: number
}

@Component
export struct LineChart {
  @Prop data: CalorieTrend[] = []
  @Prop title: string = ''
  @Prop lineColor: string = DT.BRAND_PRIMARY
  @Prop targetColor: string = '#FF6B6B'
  @Prop showTarget: boolean = true
  @Prop isDark: boolean = false

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  )

  private canvasWidth: number = 300
  private canvasHeight: number = 220
  private paddingTop: number = 30
  private paddingRight: number = 20
  private paddingBottom: number = 40
  private paddingLeft: number = 50

  private getGridColor(): string {
    return this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)'
  }

  private getTextColor(): string {
    return this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY
  }

  private getBgColor(): string {
    return this.isDark ? DT.DARK_SURFACE : '#FFFFFF'
  }

  private drawLineChart(canvasContext: CanvasRenderingContext2D): void {
    if (this.data.length === 0) return

    const chartWidth = this.canvasWidth - this.paddingLeft - this.paddingRight
    const chartHeight = this.canvasHeight - this.paddingTop - this.paddingBottom

    canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight)

    const maxValue = Math.max(
      ...this.data.map(d => Math.max(d.calories, d.target)),
      1
    ) * 1.1

    // Draw subtle grid lines
    canvasContext.strokeStyle = this.getGridColor()
    canvasContext.lineWidth = 1
    canvasContext.setLineDash([4, 4])

    for (let i = 0; i <= 4; i++) {
      const y = this.paddingTop + (chartHeight / 4) * i
      canvasContext.beginPath()
      canvasContext.moveTo(this.paddingLeft, y)
      canvasContext.lineTo(this.paddingLeft + chartWidth, y)
      canvasContext.stroke()
    }
    canvasContext.setLineDash([])

    // Draw Y-axis labels
    canvasContext.fillStyle = this.getTextColor()
    canvasContext.font = '11px sans-serif'
    canvasContext.textAlign = 'right'

    for (let i = 0; i <= 4; i++) {
      const y = this.paddingTop + (chartHeight / 4) * i
      const value = Math.round(maxValue * (4 - i) / 4)
      canvasContext.fillText(value.toString(), this.paddingLeft - 10, y + 4)
    }

    // Calculate points with bezier curve control points
    let points: Point[] = []
    for (let i = 0; i < this.data.length; i++) {
      points.push({
        x: this.paddingLeft + (chartWidth / (this.data.length - 1)) * i,
        y: this.paddingTop + chartHeight * (1 - this.data[i].calories / maxValue)
      })
    }

    // Create gradient for area fill
    const gradient = canvasContext.createLinearGradient(0, this.paddingTop, 0, this.canvasHeight - this.paddingBottom)
    gradient.addColorStop(0, this.lineColor + '40')
    gradient.addColorStop(1, this.lineColor + '00')

    // Draw area fill
    if (points.length > 1) {
      canvasContext.fillStyle = gradient
      canvasContext.beginPath()
      canvasContext.moveTo(points[0].x, points[0].y)

      for (let i = 0; i < points.length - 1; i++) {
        const cp1x = points[i].x + (points[i + 1].x - points[i].x) * 0.3
        const cp1y = points[i].y
        const cp2x = points[i + 1].x - (points[i + 1].x - points[i].x) * 0.3
        const cp2y = points[i + 1].y
        canvasContext.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, points[i + 1].x, points[i + 1].y)
      }

      canvasContext.lineTo(points[points.length - 1].x, this.canvasHeight - this.paddingBottom)
      canvasContext.lineTo(points[0].x, this.canvasHeight - this.paddingBottom)
      canvasContext.closePath()
      canvasContext.fill()
    }

    // Draw target line
    if (this.showTarget && this.data.length > 0) {
      const targetY = this.paddingTop + chartHeight * (1 - this.data[0].target / maxValue)
      canvasContext.strokeStyle = this.targetColor
      canvasContext.setLineDash([6, 4])
      canvasContext.lineWidth = 2
      canvasContext.beginPath()
      canvasContext.moveTo(this.paddingLeft, targetY)
      canvasContext.lineTo(this.paddingLeft + chartWidth, targetY)
      canvasContext.stroke()
      canvasContext.setLineDash([])

      // Target label
      canvasContext.fillStyle = this.targetColor
      canvasContext.font = '10px sans-serif'
      canvasContext.textAlign = 'left'
      canvasContext.fillText('目标', this.paddingLeft + chartWidth + 5, targetY + 3)
    }

    // Draw smooth line
    if (points.length > 1) {
      canvasContext.strokeStyle = this.lineColor
      canvasContext.lineWidth = 3
      canvasContext.lineCap = 'round'
      canvasContext.lineJoin = 'round'
      canvasContext.beginPath()
      canvasContext.moveTo(points[0].x, points[0].y)

      for (let i = 0; i < points.length - 1; i++) {
        const cp1x = points[i].x + (points[i + 1].x - points[i].x) * 0.3
        const cp1y = points[i].y
        const cp2x = points[i + 1].x - (points[i + 1].x - points[i].x) * 0.3
        const cp2y = points[i + 1].y
        canvasContext.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, points[i + 1].x, points[i + 1].y)
      }
      canvasContext.stroke()
    }

    // Draw data points with glow effect
    points.forEach((point, index) => {
      // Outer glow
      canvasContext.fillStyle = this.lineColor + '30'
      canvasContext.beginPath()
      canvasContext.arc(point.x, point.y, 8, 0, 2 * Math.PI)
      canvasContext.fill()

      // Middle ring
      canvasContext.fillStyle = this.isDark ? DT.DARK_SURFACE : '#FFFFFF'
      canvasContext.beginPath()
      canvasContext.arc(point.x, point.y, 5, 0, 2 * Math.PI)
      canvasContext.fill()

      // Inner dot
      canvasContext.fillStyle = this.lineColor
      canvasContext.beginPath()
      canvasContext.arc(point.x, point.y, 3, 0, 2 * Math.PI)
      canvasContext.fill()
    })

    // Draw X-axis labels
    canvasContext.fillStyle = this.getTextColor()
    canvasContext.font = '11px sans-serif'
    canvasContext.textAlign = 'center'

    const labelIndices = [0, Math.floor(this.data.length / 2), this.data.length - 1]
    labelIndices.forEach(index => {
      if (index >= 0 && index < this.data.length) {
        const x = this.paddingLeft + (chartWidth / (this.data.length - 1)) * index
        const date = this.data[index].date
        const label = date.substring(5)
        canvasContext.fillText(label, x, this.canvasHeight - 15)
      }
    })

    // Draw value labels on max and min points
    if (points.length > 0) {
      const maxPoint = points.reduce((max, p) => p.y < max.y ? p : max, points[0])
      const minPoint = points.reduce((min, p) => p.y > min.y ? p : min, points[0])

      canvasContext.fillStyle = this.getTextColor()
      canvasContext.font = 'bold 11px sans-serif'
      canvasContext.textAlign = 'center'

      canvasContext.fillText(Math.round(this.data[points.indexOf(maxPoint)].calories).toString(), maxPoint.x, maxPoint.y - 12)
      canvasContext.fillText(Math.round(this.data[points.indexOf(minPoint)].calories).toString(), minPoint.x, minPoint.y + 20)
    }
  }

  build() {
    Column({ space: 12 }) {
      if (this.title) {
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY)
          .width('100%')
      }

      Canvas(this.context)
        .width('100%')
        .height(this.canvasHeight)
        .backgroundColor(this.getBgColor())
        .borderRadius(16)
        .shadow(this.isDark ? undefined : {
          radius: 8,
          color: 'rgba(0,0,0,0.04)',
          offsetX: 0,
          offsetY: 2
        })
        .onReady(() => {
          this.drawLineChart(this.context)
        })
        .onAreaChange(() => {
          this.drawLineChart(this.context)
        })
    }
    .width('100%')
  }
}

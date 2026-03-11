/**
 * Pie Chart Component - Optimized
 * 饼图组件 - 优化版
 */

import { ExpenseByCategory } from '../../models/AccountingModels'
import { DesignTokens as DT } from '../../constants/DesignTokens'

@Component
export struct PieChart {
  @Prop data: ExpenseByCategory[] = []
  @Prop title: string = ''
  @Prop showLegend: boolean = true
  @Prop isDark: boolean = false

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  )

  private getTextColor(): string {
    return this.isDark ? DT.DARK_TEXT_PRIMARY : DT.LIGHT_TEXT_PRIMARY
  }

  private getTextSecondaryColor(): string {
    return this.isDark ? DT.DARK_TEXT_SECONDARY : DT.LIGHT_TEXT_SECONDARY
  }

  private getBgColor(): string {
    return this.isDark ? DT.DARK_SURFACE : '#FFFFFF'
  }

  private getHoleColor(): string {
    return this.isDark ? DT.DARK_SURFACE : '#FFFFFF'
  }

  private drawPieChart(canvasContext: CanvasRenderingContext2D): void {
    if (this.data.length === 0) return

    const canvasWidth = 300
    const canvasHeight = this.showLegend ? 280 : 200
    const centerX = canvasWidth / 2
    const centerY = 100
    const outerRadius = 75
    const innerRadius = 45
    const gap = 0.04 // Gap between slices in radians

    // Clear canvas
    canvasContext.clearRect(0, 0, canvasWidth, canvasHeight)

    const total = this.data.reduce((sum, item) => sum + item.amount, 0)
    let currentAngle = -Math.PI / 2 // Start from top

    // Draw pie slices with gap
    this.data.forEach(item => {
      const sliceAngle = (item.amount / total) * 2 * Math.PI - gap
      const midAngle = currentAngle + sliceAngle / 2

      // Calculate offset for exploded effect on largest slice
      const isLargest = item.amount === Math.max(...this.data.map(d => d.amount))
      const offsetX = isLargest ? Math.cos(midAngle) * 6 : 0
      const offsetY = isLargest ? Math.sin(midAngle) * 6 : 0

      // Draw outer arc
      canvasContext.fillStyle = item.color
      canvasContext.beginPath()
      canvasContext.arc(centerX + offsetX, centerY + offsetY, outerRadius, currentAngle, currentAngle + sliceAngle)
      canvasContext.arc(centerX + offsetX, centerY + offsetY, innerRadius, currentAngle + sliceAngle, currentAngle, true)
      canvasContext.closePath()
      canvasContext.fill()

      // Draw shadow for depth effect
      if (!this.isDark) {
        canvasContext.save()
        canvasContext.shadowColor = item.color + '40'
        canvasContext.shadowBlur = 10
        canvasContext.shadowOffsetX = 2
        canvasContext.shadowOffsetY = 2
        canvasContext.fill()
        canvasContext.restore()
      }

      currentAngle += sliceAngle + gap
    })

    // Draw center hole
    canvasContext.fillStyle = this.getHoleColor()
    canvasContext.beginPath()
    canvasContext.arc(centerX, centerY, innerRadius - 2, 0, 2 * Math.PI)
    canvasContext.fill()

    // Draw center text with better typography
    canvasContext.fillStyle = this.getTextColor()
    canvasContext.font = 'bold 18px sans-serif'
    canvasContext.textAlign = 'center'
    canvasContext.fillText('¥' + total.toFixed(0), centerX, centerY - 4)

    canvasContext.fillStyle = this.getTextSecondaryColor()
    canvasContext.font = '12px sans-serif'
    canvasContext.fillText('总支出', centerX, centerY + 16)

    // Draw legend in grid layout
    if (this.showLegend) {
      const legendY = 190
      const cols = Math.min(this.data.length, 3)
      const itemWidth = canvasWidth / cols

      this.data.forEach((item, index) => {
        const col = index % cols
        const row = Math.floor(index / cols)
        const x = col * itemWidth + itemWidth / 2
        const y = legendY + row * 45

        // Color dot with subtle shadow
        if (!this.isDark) {
          canvasContext.shadowColor = item.color + '60'
          canvasContext.shadowBlur = 6
          canvasContext.shadowOffsetX = 0
          canvasContext.shadowOffsetY = 2
        }
        canvasContext.fillStyle = item.color
        canvasContext.beginPath()
        canvasContext.arc(x - 30, y, 6, 0, 2 * Math.PI)
        canvasContext.fill()
        canvasContext.shadowBlur = 0

        // Category name
        canvasContext.fillStyle = this.getTextColor()
        canvasContext.font = '12px sans-serif'
        canvasContext.textAlign = 'left'
        canvasContext.fillText(item.category, x - 18, y + 4)

        // Percentage
        canvasContext.fillStyle = this.getTextSecondaryColor()
        canvasContext.font = '11px sans-serif'
        canvasContext.fillText(item.percentage.toFixed(1) + '%', x - 18, y + 18)
      })
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
        .height(this.showLegend ? 280 : 200)
        .backgroundColor(this.getBgColor())
        .borderRadius(16)
        .shadow(this.isDark ? undefined : {
          radius: 8,
          color: 'rgba(0,0,0,0.04)',
          offsetX: 0,
          offsetY: 2
        })
        .onReady(() => {
          this.drawPieChart(this.context)
        })
        .onAreaChange(() => {
          this.drawPieChart(this.context)
        })
    }
    .width('100%')
  }
}

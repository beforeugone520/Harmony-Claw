/**
 * HmCard.ets
 * HarmonyOS 6 风格卡片组件
 */
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../../constants'

@Component
export struct HmCard {
  @Prop cardPadding: number = SP.CARD_PADDING
  @Prop cardBgColor: ResourceColor = DT.LIGHT_BG_PRIMARY
  @Prop cardBorderRadius: number = SP.RADIUS_L
  @Prop cardClickable: boolean = false
  onCardClick?: () => void

  @BuilderParam cardContent: () => void

  build() {
    Column() {
      this.cardContent()
    }
    .width('100%')
    .backgroundColor(this.cardBgColor)
    .borderRadius(this.cardBorderRadius)
    .padding(this.cardPadding)
    .shadow({
      radius: 8,
      color: DT.SHADOW_LIGHT,
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.cardClickable && this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}

@Component
export struct HmListCard {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop status: string = ''
  @Prop statusColor: ResourceColor = DT.LIGHT_TEXT_SECONDARY
  onListCardClick?: () => void

  build() {
    HmCard({
      cardPadding: SP.M,
      cardBgColor: DT.LIGHT_BG_PRIMARY,
      cardBorderRadius: SP.RADIUS_M,
      cardClickable: true,
      onCardClick: this.onListCardClick
    }) {
      Row() {
        Column({ space: SP.XS }) {
          Row() {
            Text(this.title)
              .fontSize(TYP.SIZE_BODY)
              .fontWeight(TYP.WEIGHT_MEDIUM)
              .fontColor(DT.LIGHT_TEXT_PRIMARY)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            if (this.status) {
              Text(this.status)
                .fontSize(TYP.SIZE_SMALL)
                .fontColor(this.statusColor)
                .backgroundColor(DT.LIGHT_BG_SECONDARY)
                .padding({ left: SP.S, right: SP.S, top: 2, bottom: 2 })
                .borderRadius(SP.RADIUS_XS)
            }
          }
          .width('100%')

          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('›')
          .fontSize(20)
          .fontColor(DT.LIGHT_TEXT_TERTIARY)
          .margin({ left: SP.S })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
  }
}

@Component
export struct HmInfoCard {
  @Prop infoTitle: string = ''
  @Prop infoValue: string = ''
  @Prop infoUnit: string = ''
  @Prop infoIcon: string = ''
  @Prop infoIconBg: ResourceColor = DT.BRAND_LIGHT
  @Prop infoIconColor: ResourceColor = DT.BRAND_PRIMARY

  build() {
    HmCard({
      cardPadding: SP.L,
      cardBgColor: DT.LIGHT_BG_PRIMARY,
      cardBorderRadius: SP.RADIUS_L
    }) {
      Column({ space: SP.S }) {
        Text(this.infoIcon)
          .fontSize(24)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.infoIconBg)
          .borderRadius(SP.RADIUS_M)

        Text(this.infoTitle)
          .fontSize(TYP.SIZE_CAPTION)
          .fontColor(DT.LIGHT_TEXT_SECONDARY)

        Row() {
          Text(this.infoValue)
            .fontSize(28)
            .fontWeight(TYP.WEIGHT_BOLD)
            .fontColor(DT.LIGHT_TEXT_PRIMARY)

          if (this.infoUnit) {
            Text(this.infoUnit)
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
              .margin({ left: SP.XS })
              .align(Alignment.Bottom)
          }
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

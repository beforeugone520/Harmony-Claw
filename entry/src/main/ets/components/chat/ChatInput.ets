import { Colors, Typography } from '../../styles/DesignTokens';
import { Spacing, Layout } from '../../styles/Spacing';

@Component
export struct ChatInput {
  @State inputText: string = '';
  onSend?: (text: string) => void;

  private canSend(): boolean {
    return this.inputText.trim().length > 0;
  }

  private handleSend(): void {
    if (this.canSend() && this.onSend) {
      this.onSend(this.inputText.trim());
      this.inputText = '';
    }
  }

  build() {
    Row({ space: Spacing.md }) {
      TextInput({ placeholder: '输入消息...', text: $$this.inputText })
        .placeholderColor(Colors.textTertiary)
        .fontSize(Typography.sizeBody)
        .height(44)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(22)
        .padding({ left: Spacing.md, right: Spacing.md })
        .layoutWeight(1)

      Button('发送')
        .width(80)
        .height(44)
        .backgroundColor(this.canSend() ? Colors.brandPrimary : Colors.backgroundTertiary)
        .fontColor(this.canSend() ? Colors.textInverse : Colors.textTertiary)
        .fontSize(Typography.sizeBody)
        .enabled(this.canSend())
        .onClick(() => this.handleSend())
    }
    .width('100%')
    .height(Layout.tabBarHeight)
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .backgroundColor(Colors.backgroundSecondary)
    .border({ width: { top: 1 }, color: Colors.borderLight })
  }
}

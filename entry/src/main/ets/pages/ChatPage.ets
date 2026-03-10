import { router } from '@kit.ArkUI';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { MessageBubble } from '../components/chat/MessageBubble';
import { ChatInput } from '../components/chat/ChatInput';
import { SessionItem } from '../components/chat/SessionItem';
import { Message } from '../models/Message';
import { Session } from '../models/Session';
import { Colors, Typography } from '../styles/DesignTokens';
import { Spacing, Layout } from '../styles/Spacing';
import { LoadingState } from '../components/LoadingState';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct ChatPage {
  @State viewModel: ChatViewModel = new ChatViewModel();
  @State showNewSessionDialog: boolean = false;
  @State newSessionTitle: string = '';
  private listScroller: ListScroller = new ListScroller();

  aboutToAppear() {
    console.log('[ChatPage] aboutToAppear called');
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[ChatPage] Failed to initialize: ${JSON.stringify(e)}`);
    });
  }

  private async handleSendMessage(text: string) {
    try {
      if (!this.viewModel.currentSession) {
        const session = await this.viewModel.createSession('新会话');
        if (session) {
          await this.viewModel.selectSession(session);
        }
      }
      await this.viewModel.sendMessage(text);
    } catch (e) {
      console.error(`[ChatPage] handleSendMessage failed: ${JSON.stringify(e)}`);
    }
  }

  private async handleCreateSession() {
    try {
      const session = await this.viewModel.createSession(this.newSessionTitle || undefined);
      if (session) {
        this.showNewSessionDialog = false;
        this.newSessionTitle = '';
        await this.viewModel.selectSession(session);
      }
    } catch (e) {
      console.error(`[ChatPage] handleCreateSession failed: ${JSON.stringify(e)}`);
    }
  }

  @Builder
  NewSessionDialog() {
    Column({ space: Spacing.lg }) {
      Text('新建会话')
        .fontSize(Typography.sizeH3)
        .fontWeight(Typography.weightBold)
        .fontColor(Colors.textPrimary)

      TextInput({ placeholder: '会话标题 (可选)', text: $$this.newSessionTitle })
        .width('100%')
        .height(44)
        .placeholderColor(Colors.textTertiary)
        .backgroundColor(Colors.backgroundTertiary)
        .borderRadius(8)

      Row({ space: Spacing.md }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Colors.backgroundTertiary)
          .fontColor(Colors.textPrimary)
          .onClick(() => {
            this.showNewSessionDialog = false;
          })

        Button('创建')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Colors.brandPrimary)
          .onClick(() => this.handleCreateSession())
      }
      .width('100%')
    }
    .width('80%')
    .padding(Spacing.lg)
    .backgroundColor(Colors.surfaceCard)
    .borderRadius(16)
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        // Header
        Row() {
          Text(this.viewModel.currentSession?.title || '对话中心')
            .fontSize(Typography.sizeH3)
            .fontWeight(Typography.weightBold)
            .fontColor(Colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor(Colors.brandPrimary)
            .fontColor(Colors.textInverse)
            .fontSize(24)
            .onClick(() => {
              this.showNewSessionDialog = true;
            })
        }
        .width('100%')
        .height(Layout.headerHeight)
        .padding({ left: Spacing.lg, right: Spacing.lg })
        .backgroundColor(Colors.backgroundSecondary)

        // Session List (Horizontal)
        if (this.viewModel.sessions.length > 0) {
          List({ space: Spacing.sm }) {
            ForEach(this.viewModel.sessions, (session: Session) => {
              ListItem() {
                Column({ space: Spacing.xs }) {
                  Text(session.title || '未命名')
                    .fontSize(Typography.sizeSmall)
                    .fontColor(this.viewModel.currentSession?.id === session.id ?
                      Colors.brandPrimary : Colors.textSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width(80)

                  if (this.viewModel.currentSession?.id === session.id) {
                    Divider()
                      .width(40)
                      .height(2)
                      .color(Colors.brandPrimary)
                  }
                }
                .padding(Spacing.sm)
                .onClick(() => {
                  this.viewModel.selectSession(session);
                })
              }
            }, (session: Session) => session.id)
          }
          .width('100%')
          .height(50)
          .padding({ left: Spacing.md, right: Spacing.md })
          .listDirection(Axis.Horizontal)
          .backgroundColor(Colors.backgroundSecondary)
        }

        // Message List
        if (this.viewModel.isLoading && this.viewModel.messages.length === 0) {
          LoadingState({ message: '加载消息...' })
        } else if (this.viewModel.messages.length === 0) {
          EmptyState({
            title: '开始对话',
            message: '输入消息开始与 AI 对话'
          })
        } else {
          List({ scroller: this.listScroller, space: Spacing.md }) {
            ForEach(this.viewModel.messages, (message: Message) => {
              ListItem() {
                MessageBubble({ message: message })
              }
            }, (message: Message) => message.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ top: Spacing.md, bottom: Spacing.md })
        }

        // Input
        ChatInput({
          onSend: (text: string) => { this.handleSendMessage(text); }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.backgroundPrimary)

      // New Session Dialog
      if (this.showNewSessionDialog) {
        Column() {
          this.NewSessionDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
}

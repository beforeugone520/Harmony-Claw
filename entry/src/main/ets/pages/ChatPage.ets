import { router } from '@kit.ArkUI';
import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { MessageBubble } from '../components/chat/MessageBubble';
import { ChatInput } from '../components/chat/ChatInput';
import { SessionItem } from '../components/chat/SessionItem';
import { Message } from '../models/Message';
import { Session } from '../models/Session';
import { Spacing as SP } from '../constants';
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

  private async handleSendMessage(text: string): Promise<void> {
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

  private async handleCreateSession(): Promise<void> {
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
    Column({ space: SP.L }) {
      Text('新建会话')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      TextInput({ placeholder: '会话标题 (可选)', text: $$this.newSessionTitle })
        .width('100%')
        .height(44)
        .placeholderColor($r('app.color.text_tertiary'))
        .backgroundColor($r('app.color.background_tertiary'))
        .borderRadius(8)

      Row({ space: SP.M }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.background_tertiary'))
          .fontColor($r('app.color.text_primary'))
          .onClick((): void => {
            this.showNewSessionDialog = false;
          })

        Button('创建')
          .layoutWeight(1)
          .height(44)
          .backgroundColor($r('app.color.brand_primary'))
          .onClick(() => { this.handleCreateSession().catch((e: Error) => console.error(JSON.stringify(e))); })
      }
      .width('100%')
    }
    .width('80%')
    .padding(SP.L)
    .backgroundColor($r('app.color.surface_card'))
    .borderRadius(16)
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        // Header
        Row() {
          Text(this.viewModel.currentSession?.title || '对话中心')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.brand_primary'))
            .fontColor($r('app.color.text_inverse'))
            .fontSize(24)
            .onClick((): void => {
              this.showNewSessionDialog = true;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: SP.L, right: SP.L })
        .backgroundColor($r('app.color.background_secondary'))

        // Session List (Horizontal)
        if (this.viewModel.sessions.length > 0) {
          List({ space: SP.S }) {
            ForEach(this.viewModel.sessions, (session: Session) => {
              ListItem() {
                Column({ space: SP.XS }) {
                  Text(session.title || '未命名')
                    .fontSize(12)
                    .fontColor(this.viewModel.currentSession?.id === session.id ?
                      $r('app.color.brand_primary') : $r('app.color.text_secondary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width(80)

                  if (this.viewModel.currentSession?.id === session.id) {
                    Divider()
                      .width(40)
                      .height(2)
                      .color($r('app.color.brand_primary'))
                  }
                }
                .padding(SP.S)
                .onClick(() => {
                  this.viewModel.selectSession(session);
                })
              }
            }, (session: Session) => session.id)
          }
          .width('100%')
          .height(50)
          .padding({ left: SP.M, right: SP.M })
          .listDirection(Axis.Horizontal)
          .backgroundColor($r('app.color.background_secondary'))
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
          List({ scroller: this.listScroller, space: SP.M }) {
            ForEach(this.viewModel.messages, (message: Message) => {
              ListItem() {
                MessageBubble({ message: message })
              }
            }, (message: Message) => message.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ top: SP.M, bottom: SP.M })
        }

        // Input
        ChatInput({
          onSend: (text: string) => { this.handleSendMessage(text); }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_primary'))

      // New Session Dialog
      if (this.showNewSessionDialog) {
        Column() {
          this.NewSessionDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.overlay_light'))
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

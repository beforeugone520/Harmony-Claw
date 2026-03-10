/**
 * SessionListPage.ets
 * 会话列表页面 - HarmonyOS 6 风格
 */
import { router } from '@kit.ArkUI'
import { Session, SessionStatus } from '../models/Session'
import { ChatViewModel } from '../viewmodels/ChatViewModel'
import { SessionItem } from '../components/chat/SessionItem'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmButton, HmCard, HmConfirmDialog, HmSearchInput, ToastManager } from '../components/common'
import { LoadingState } from '../components/LoadingState'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct SessionListPage {
  @State viewModel: ChatViewModel = new ChatViewModel()
  @State searchQuery: string = ''
  @State showDeleteDialog: boolean = false
  @State sessionToDelete: Session | null = null
  @State isRefreshing: boolean = false

  aboutToAppear() {
    this.viewModel.initialize().catch((e: Error) => {
      console.error(`[SessionListPage] Failed to initialize: ${e.message}`)
    })
  }

  // 获取过滤后的会话列表
  private getFilteredSessions(): Session[] {
    if (!this.searchQuery) {
      return this.viewModel.sessions
    }
    const query = this.searchQuery.toLowerCase()
    return this.viewModel.sessions.filter(session =>
      session.title?.toLowerCase().includes(query)
    )
  }

  // 创建新会话
  private async createNewSession() {
    ToastManager.loading('创建中...')
    const session = await this.viewModel.createSession('新会话')
    ToastManager.hideLoading()

    if (session) {
      ToastManager.success('会话创建成功')
      // 跳转到聊天页面
      router.pushUrl({
        url: 'pages/ChatPage',
        params: { sessionId: session.id }
      })
    } else {
      ToastManager.error('创建失败')
    }
  }

  // 选择会话
  private async selectSession(session: Session) {
    await this.viewModel.selectSession(session)
    router.pushUrl({
      url: 'pages/ChatPage',
      params: { sessionId: session.id }
    })
  }

  // 删除会话
  private async deleteSession() {
    if (!this.sessionToDelete) return

    ToastManager.loading('删除中...')
    try {
      await this.viewModel.deleteSession(this.sessionToDelete.id)
      ToastManager.success('已删除')
    } catch (e) {
      ToastManager.error('删除失败')
    } finally {
      ToastManager.hideLoading()
      this.sessionToDelete = null
    }
  }

  // 下拉刷新
  private async onRefresh() {
    this.isRefreshing = true
    await this.viewModel.loadSessions()
    this.isRefreshing = false
    ToastManager.success('已刷新')
  }

  build() {
    Navigation() {
      Column({ space: 0 }) {
        // 搜索栏
        Row() {
          HmSearchInput({
            placeholder: '搜索会话',
            value: $$this.searchQuery
          })
        }
        .width('100%')
        .padding({
          left: SP.PAGE_HORIZONTAL,
          right: SP.PAGE_HORIZONTAL,
          top: SP.M,
          bottom: SP.M
        })
        .backgroundColor(DT.LIGHT_BG_PRIMARY)

        // 统计信息
        Row({ space: SP.XL }) {
          Column({ space: SP.XS }) {
            Text(String(this.viewModel.sessions.length))
              .fontSize(24)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.BRAND_PRIMARY)
            Text('总会话')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }

          Column({ space: SP.XS }) {
            Text(String(this.viewModel.sessions.filter(s => s.status === SessionStatus.ACTIVE).length))
              .fontSize(24)
              .fontWeight(TYP.WEIGHT_BOLD)
              .fontColor(DT.SUCCESS)
            Text('进行中')
              .fontSize(TYP.SIZE_CAPTION)
              .fontColor(DT.LIGHT_TEXT_SECONDARY)
          }
        }
        .width('100%')
        .padding(SP.L)
        .backgroundColor(DT.LIGHT_BG_PRIMARY)

        // 会话列表
        if (this.viewModel.isLoading && this.viewModel.sessions.length === 0) {
          LoadingState({ message: '加载中...' })
        } else if (this.getFilteredSessions().length === 0) {
          EmptyState({
            title: this.searchQuery ? '未找到会话' : '暂无会话',
            message: this.searchQuery
              ? '尝试其他关键词搜索'
              : '点击右上角 + 按钮创建新会话'
          })
        } else {
          Refresh({ refreshing: $$this.isRefreshing }) {
            List({ space: SP.CARD_GAP }) {
              ForEach(this.getFilteredSessions(), (session: Session) => {
                ListItem() {
                  SessionItem({
                    session: session,
                    isSelected: this.viewModel.currentSession?.id === session.id,
                    onItemClick: () => this.selectSession(session),
                    onDelete: () => {
                      this.sessionToDelete = session
                      this.showDeleteDialog = true
                    }
                  })
                }
                .swipeAction({
                  end: {
                    builder: () => this.DeleteButton(session)
                  }
                })
              }, (session: Session) => session.id)
            }
            .width('100%')
            .padding(SP.PAGE_HORIZONTAL)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)
          }
          .onRefreshing(() => this.onRefresh())
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DT.LIGHT_BG_SECONDARY)
    }
    .title('会话列表')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor(DT.LIGHT_BG_SECONDARY)
    .toolbarConfiguration([
      {
        value: '新建',
        icon: $r('app.media.ic_add'),
        action: () => this.createNewSession()
      }
    ])
    // 删除确认对话框
    .overlay(
      HmConfirmDialog({
        visible: this.showDeleteDialog,
        title: '删除会话',
        message: `确定要删除"${this.sessionToDelete?.title || '未命名会话'}"吗？此操作不可撤销。`,
        confirmText: '删除',
        cancelText: '取消',
        danger: true,
        onConfirm: () => {
          this.showDeleteDialog = false
          this.deleteSession()
        },
        onCancel: () => {
          this.showDeleteDialog = false
          this.sessionToDelete = null
        }
      })
    )
  }

  // 删除按钮构建器
  @Builder
  DeleteButton(session: Session) {
    Column() {
      Image($r('app.media.ic_delete'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
    }
    .width(64)
    .height(72)
    .backgroundColor(DT.ERROR)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.sessionToDelete = session
      this.showDeleteDialog = true
    })
  }
}

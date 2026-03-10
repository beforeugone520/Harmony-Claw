/**
 * SessionListPage.ets
 * 会话列表页面 - HarmonyOS 6 风格
 */
import { router } from '@kit.ArkUI'
import { Session, SessionStatus } from '../models/Session'
import { ChatViewModel } from '../viewmodels/ChatViewModel'
import { SessionItem } from '../components/chat/SessionItem'
import { DesignTokens as DT, Spacing as SP, Typography as TYP } from '../constants'
import { HmConfirmDialog, HmSearchInput, ToastManager } from '../components/common'
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
            searchPlaceholder: '搜索会话',
            searchValue: this.searchQuery,
            onSearchChange: (value: string) => { this.searchQuery = value }
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
                    onItemClick: (): void => { this.selectSession(session) },
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
        icon: $r('app.media.startIcon'),
        action: (): void => { this.createNewSession() }
      }
    ])
    .overlay(this.deleteDialogBuilder())
  }

  @Builder
  deleteDialogBuilder() {
    HmConfirmDialog({
      confirmVisible: this.showDeleteDialog,
      confirmTitle: '删除会话',
      confirmMessage: `确定要删除"${this.sessionToDelete?.title || '未命名会话'}"吗？`,
      confirmBtnText: '删除',
      cancelBtnText: '取消',
      isDanger: true,
      onConfirm: (): void => {
        this.showDeleteDialog = false
        this.deleteSession()
      },
      onCancel: (): void => {
        this.showDeleteDialog = false
        this.sessionToDelete = null
      }
    })
  }

  @Builder
  DeleteButton(session: Session) {
    Column() {
      Text('🗑')
        .fontSize(20)
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

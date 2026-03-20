import { router } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { MemoryCard } from '../model/MemoryCard';
import { GlassmorphicCard } from '../components/GlassmorphicCard';
import { MemoryCardComponent } from '../components/MemoryCard';

@Entry
@Component
struct HomePage {
  @State memories: MemoryCard[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;

  async aboutToAppear() {
    await this.loadMemories();
  }

  async loadMemories() {
    try {
      this.memories = await storageService.queryAll();
    } catch (err) {
      console.error('Failed to load memories:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  onPageShow() {
    // 每次页面显示时刷新数据
    this.loadMemories();
  }

  build() {
    Stack() {
      // 背景
      Column() {
        // 渐变背景
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [
          ['#1a1a2e', 0],
          ['#16213e', 0.5],
          ['#0f3460', 1]
        ]
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 主内容
      Column() {
        // 标题栏
        Row() {
          Text('回忆流')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .justifyContent(FlexAlign.Start)

        // 回忆列表
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .color('#FFFFFF')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.memories.length === 0) {
          Column() {
            Text('还没有回忆')
              .fontSize(18)
              .fontColor('rgba(255, 255, 255, 0.6)')
              .margin({ bottom: 8 })
            Text('开始记录第一个美好时刻吧')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.4)')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 16 }) {
            ForEach(this.memories, (memory: MemoryCard) => {
              ListItem() {
                MemoryCardComponent({
                  memory: memory,
                  onCardClick: (): void => {
                    router.pushUrl({
                      url: 'pages/MemoryDetailPage',
                      params: { memoryId: memory.id }
                    });
                  }
                })
              }
              .padding({ left: 16, right: 16 })
            })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')

      // 底部"记录此刻"按钮
      Column() {
        Row() {
          Text('+')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .margin({ right: 8 })
          Text('记录此刻')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
      }
      .width(180)
      .height(56)
      .backgroundColor('rgba(255, 255, 255, 0.25)')
      .backdropBlur(20)
      .borderRadius(28)
      .border({
        width: 1,
        color: 'rgba(255, 255, 255, 0.3)'
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .position({ bottom: 36 })
      .onClick((): void => {
        router.pushUrl({
          url: 'pages/CreateMemoryPage'
        });
      })
    }
    .width('100%')
    .height('100%')
  }
}

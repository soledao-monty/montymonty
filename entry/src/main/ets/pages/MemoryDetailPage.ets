import { router, promptAction } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { MemoryCard } from '../model/MemoryCard';
import { formatDate } from '../utils/dateFormat';
import { GlassmorphicCard, GlassmorphicCardDark } from '../components/GlassmorphicCard';

@Entry
@Component
struct MemoryDetailPage {
  @State memory: MemoryCard | null = null;
  @State isLoading: boolean = true;
  @State currentImageIndex: number = 0;
  @State showImageViewer: boolean = false;
  @State isDeleting: boolean = false;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    const memoryId = params?.memoryId;

    if (memoryId) {
      try {
        this.memory = await storageService.queryById(memoryId);
      } catch (err) {
        console.error('Failed to load memory:', JSON.stringify(err));
      }
    }
    this.isLoading = false;
  }

  async deleteMemory() {
    if (!this.memory || this.isDeleting) return;

    this.isDeleting = true;
    try {
      await storageService.delete(this.memory.id);
      promptAction.showToast({ message: '删除成功' });
      router.back();
    } catch (err) {
      console.error('Failed to delete memory:', JSON.stringify(err));
      promptAction.showToast({ message: '删除失败' });
    } finally {
      this.isDeleting = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color('#FFFFFF')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (!this.memory) {
        Column() {
          Text('回忆不存在')
            .fontSize(18)
            .fontColor('rgba(255, 255, 255, 0.6)')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 顶部导航
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .onClick((): void => {
              router.back();
            })

          Blank()

          Text(this.isDeleting ? '删除中...' : '删除')
            .fontSize(16)
            .fontColor('#FF6B6B')
            .onClick((): void => {
              if (!this.isDeleting) {
                this.deleteMemory();
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 50, bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll() {
          Column({ space: 20 }) {
            // 照片轮播/网格
            if (this.memory.mediaUris.length === 1) {
              Image(this.memory.mediaUris[0])
                .width('100%')
                .height(300)
                .borderRadius(16)
                .objectFit(ImageFit.Cover)
            } else {
              // 多张照片网格展示
              Grid() {
                ForEach(this.memory.mediaUris, (uri: string, index: number) => {
                  GridItem() {
                    Image(uri)
                      .width('100%')
                      .height('100%')
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                  }
                })
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
              .height(Math.ceil(this.memory.mediaUris.length / 2) * 180)
            }

            // 时间和地点
            GlassmorphicCardDark({
              blurRadius: 15,
              cardOpacity: 0.2,
              cardBorderRadius: 16,
              cardPadding: 16
            }) {
              Column({ space: 12 }) {
                // 时间
                Row() {
                  Text('时间')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                  Text(formatDate(this.memory.timestamp))
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                }
                .width('100%')

                // 地点
                if (this.memory.location) {
                  Divider()
                    .color('rgba(255, 255, 255, 0.1)')

                  Row() {
                    Text('地点')
                      .fontSize(14)
                      .fontColor('rgba(255, 255, 255, 0.6)')
                    Text(this.memory.location)
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                  }
                  .width('100%')
                }

                // 照片数量
                Divider()
                  .color('rgba(255, 255, 255, 0.1)')

                Row() {
                  Text('照片')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                  Text(`${this.memory.mediaUris.length} 张`)
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            // 描述
            GlassmorphicCardDark({
              blurRadius: 15,
              cardOpacity: 0.2,
              cardBorderRadius: 16,
              cardPadding: 16
            }) {
              Column({ space: 8 }) {
                Text('回忆')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.6)')
                  .margin({ bottom: 8 })
                Text(this.memory.description)
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .lineHeight(24)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }
          .padding({ left: 16, right: 16, bottom: 40 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }
}

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

  // 判断是否是视频
  isVideo(uri: string): boolean {
    const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.m4v'];
    const lowerUri = uri.toLowerCase();
    return videoExtensions.some(ext => lowerUri.endsWith(ext));
  }

  // 打开图片预览
  openImageViewer(index: number): void {
    this.currentImageIndex = index;
    this.showImageViewer = true;
  }

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
    Stack() {
      // 背景：封面图片 + 厚重模糊 + 扩展安全区
      if (this.memory && this.memory.mediaUris.length > 0) {
        Image(this.memory.mediaUris[0])
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .blur(40)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }

      // 半透明遮罩 + 扩展安全区
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(26, 26, 46, 0.9)')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 内容层
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

            // 编辑按钮
            Text('编辑')
              .fontSize(16)
              .fontColor('rgba(255, 255, 255, 0.8)')
              .margin({ right: 16 })
              .onClick((): void => {
                if (this.memory) {
                  router.pushUrl({
                    url: 'pages/EditMemoryPage',
                    params: { memoryId: this.memory.id }
                  });
                }
              })

            Text(this.isDeleting ? '删除中...' : '删除')
              .fontSize(16)
              .fontColor('#FF6B6B')
              .onClick((): void => {
                if (!this.isDeleting) {
                  // 显示确认弹窗
                  AlertDialog.show({
                    title: '确认删除',
                    message: '确定要删除这条回忆吗？删除后无法恢复。',
                    primaryButton: {
                      value: '取消',
                      action: (): void => {
                        // 取消删除
                      }
                    },
                    secondaryButton: {
                      value: '删除',
                      action: (): void => {
                        this.deleteMemory();
                      },
                      fontColor: '#FF6B6B'
                    }
                  });
                }
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20, bottom: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Column({ space: 20 }) {
              // 照片轮播/网格
              if (this.memory.mediaUris.length === 1) {
                Stack() {
                  if (this.isVideo(this.memory.mediaUris[0])) {
                    Video({
                      src: this.memory.mediaUris[0]
                    })
                      .width('100%')
                      .height(300)
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      .autoPlay(true)
                      .controls(true)
                  } else {
                    Image(this.memory.mediaUris[0])
                      .width('100%')
                      .height(300)
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                  }
                }
                .width('100%')
                .height(300)
                .borderRadius(16)
                .onClick((): void => {
                  if (this.memory && !this.isVideo(this.memory.mediaUris[0])) {
                    this.openImageViewer(0);
                  }
                })
              } else {
                // 多张照片网格展示
                Grid() {
                  ForEach(this.memory.mediaUris, (uri: string, index: number) => {
                    GridItem() {
                      Stack() {
                        if (this.isVideo(uri)) {
                          Video({
                            src: uri
                          })
                            .width('100%')
                            .height('100%')
                            .borderRadius(8)
                            .objectFit(ImageFit.Cover)
                            .autoPlay(false)
                            .controls(true)
                        } else {
                          Image(uri)
                            .width('100%')
                            .height('100%')
                            .borderRadius(8)
                            .objectFit(ImageFit.Cover)
                        }
                      }
                      .width('100%')
                      .height('100%')
                    }
                    .onClick((): void => {
                      if (!this.isVideo(uri)) {
                        this.openImageViewer(index);
                      }
                    })
                  })
                }
                .columnsTemplate('1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .width('100%')
                .height(Math.ceil(this.memory.mediaUris.length / 2) * 180)
              }

              // 大图预览弹窗
              if (this.showImageViewer && this.memory) {
                Stack() {
                  // 背景
                  Column() {}
                    .width('100%')
                    .height('100%')
                    .backgroundColor('rgba(0, 0, 0, 0.9)')
                    .onClick((): void => {
                      this.showImageViewer = false;
                    })

                  // 照片轮播（只显示图片，过滤视频）
                  Swiper() {
                    ForEach(this.memory.mediaUris.filter((uri: string) => !this.isVideo(uri)), (uri: string) => {
                      Image(uri)
                        .width('100%')
                        .height('100%')
                        .objectFit(ImageFit.Contain)
                    })
                  }
                  .index(this.currentImageIndex)
                  .width('100%')
                  .height('100%')
                  .autoPlay(false)
                  .loop(false)
                  .indicator(false)
                  .onChange((index: number): void => {
                    this.currentImageIndex = index;
                  })

                  // 关闭按钮
                  Column() {
                    Text('×')
                      .fontSize(28)
                      .fontColor('#FFFFFF')
                  }
                  .width(44)
                  .height(44)
                  .backgroundColor('rgba(255, 255, 255, 0.2)')
                  .borderRadius(22)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .position({ top: 60, right: 16 })
                  .onClick((): void => {
                    this.showImageViewer = false;
                  })

                  // 页码指示
                  Row({ space: 8 }) {
                    Text(`${this.currentImageIndex + 1} / ${this.memory.mediaUris.length}`)
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                  }
                  .position({ bottom: 60 })
                }
                .width('100%')
                .height('100%')
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
                    Blank()
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
                      Blank()
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
                    Blank()
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
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

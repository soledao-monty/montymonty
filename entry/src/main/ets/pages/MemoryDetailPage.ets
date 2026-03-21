import { router, promptAction } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { MemoryCard } from '../model/MemoryCard';
import { formatDate } from '../utils/dateFormat';
import { GlassmorphicCard, GlassmorphicCardDark } from '../components/GlassmorphicCard';
import { OrientedImage } from '../components/OrientedImage';

// 矩形区域类型
interface RectBounds {
  x: number;
  y: number;
  width: number;
  height: number;
}

@Entry
@Component
struct MemoryDetailPage {
  @State memory: MemoryCard | null = null;
  @State isLoading: boolean = true;
  @State currentImageIndex: number = 0;
  @State isFullscreen: boolean = false;
  @State isDeleting: boolean = false;
  @State overlayOpacity: number = 0; // 遮罩透明度（动画）
  @State showOverlay: boolean = false; // 控制遮罩层显示

  // 动画相关状态
  @State animImageX: number = 0;
  @State animImageY: number = 0;
  @State animImageWidth: number = 0;
  @State animImageHeight: number = 0;
  @State isAnimating: boolean = false;

  // 布局常量
  private readonly GRID_COLUMNS: number = 2;
  private readonly GRID_SPACING: number = 8;
  private readonly SCREEN_PADDING: number = 16;
  private readonly HEADER_HEIGHT: number = 60; // 顶部导航栏高度
  private readonly ITEM_MARGIN_TOP: number = 20; // 宫格距离顶部的间距

  // 判断是否是视频
  isVideo(uri: string): boolean {
    const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.m4v'];
    const lowerUri = uri.toLowerCase();
    return videoExtensions.some(ext => lowerUri.endsWith(ext));
  }

  // 获取图片URI列表（过滤视频）
  getImageUris(): string[] {
    if (!this.memory) return [];
    return this.memory.mediaUris.filter((uri: string) => !this.isVideo(uri));
  }

  // 根据 index 计算缩略图的位置
  getThumbnailBounds(index: number, screenWidth: number): RectBounds {
    const gridWidth = screenWidth - this.SCREEN_PADDING * 2;
    const itemWidth = (gridWidth - this.GRID_SPACING) / this.GRID_COLUMNS;
    const row = Math.floor(index / this.GRID_COLUMNS);
    const col = index % this.GRID_COLUMNS;

    const x = this.SCREEN_PADDING + col * (itemWidth + this.GRID_SPACING);
    const y = this.HEADER_HEIGHT + this.ITEM_MARGIN_TOP + row * (itemWidth + this.GRID_SPACING);

    return { x: x, y: y, width: itemWidth, height: itemWidth };
  }

  // 打开全屏预览（带动画）
  openFullscreen(index: number): void {
    if (this.isAnimating) return;

    this.currentImageIndex = index;
    this.isAnimating = true;

    // 使用固定屏幕尺寸（360x780 是常见的逻辑像素尺寸）
    const screenWidth = 360;
    const screenHeight = 780;

    // 获取点击图片的起始位置
    const bounds = this.getThumbnailBounds(index, screenWidth);

    // 设置起始位置
    this.animImageX = bounds.x;
    this.animImageY = bounds.y;
    this.animImageWidth = bounds.width;
    this.animImageHeight = bounds.height;

    // 先显示遮罩（透明度为0）
    this.showOverlay = true;
    this.overlayOpacity = 0;
    this.isFullscreen = true;

    // 延迟一下让组件先渲染
    setTimeout(() => {
      // 遮罩渐变到全黑
      animateTo({
        duration: 200,
        curve: Curve.EaseInOut
      }, () => {
        this.overlayOpacity = 1;
      });

      // 图片动画放大
      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.animImageX = 0;
        this.animImageY = 0;
        this.animImageWidth = screenWidth;
        this.animImageHeight = screenHeight;
      });
    }, 50);

    // 动画完成
    setTimeout(() => {
      this.isAnimating = false;
    }, 350);
  }

  // 关闭全屏预览（直接返回）
  closeFullscreen(): void {
    // 直接关闭，不等待动画
    this.isFullscreen = false;
    this.showOverlay = false;
    this.overlayOpacity = 0;

    // 恢复图片位置
    const screenWidth = 360;
    const bounds = this.getThumbnailBounds(this.currentImageIndex, screenWidth);
    this.animImageX = bounds.x;
    this.animImageY = bounds.y;
    this.animImageWidth = bounds.width;
    this.animImageHeight = bounds.height;
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

  // 拦截返回键/侧滑手势
  onBackPress() {
    if (this.isFullscreen) {
      // 全屏状态下拦截返回，先关闭大图
      this.closeFullscreen();
      return true; // 拦截返回事件，不返回首页
    }
    return false; // 不拦截，让系统处理（返回首页）
  }

  build() {
    Stack() {
      // 背景
      if (this.memory && this.memory.mediaUris.length > 0) {
        Image(this.memory.mediaUris[0])
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .blur(40)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(26, 26, 46, 0.9)')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }

      // 页面内容（始终显示，不条件渲染）
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
            Text(this.isFullscreen ? '×' : '<')
              .fontSize(this.isFullscreen ? 28 : 24)
              .fontColor('#FFFFFF')
              .onClick((): void => {
                if (this.isFullscreen) {
                  this.closeFullscreen();
                } else {
                  router.back();
                }
              })

            Blank()

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
                  AlertDialog.show({
                    title: '确认删除',
                    message: '确定要删除这条回忆吗？删除后无法恢复。',
                    primaryButton: {
                      value: '取消',
                      action: (): void => {
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
              // 照片宫格
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
                    OrientedImage({
                      src: this.memory.mediaUris[0],
                      imgWidth: '100%',
                      imgHeight: 300,
                      radius: 16
                    })
                  }
                }
                .width('100%')
                .height(300)
                .borderRadius(16)
                .onClick((): void => {
                  if (this.memory && !this.isVideo(this.memory.mediaUris[0])) {
                    this.openFullscreen(0);
                  }
                })
              } else {
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
                          OrientedImage({
                            src: uri,
                            radius: 8
                          })
                        }
                      }
                      .width('100%')
                      .aspectRatio(1)
                    }
                    .onClick((): void => {
                      if (!this.isVideo(uri)) {
                        this.openFullscreen(index);
                      }
                    })
                  })
                }
                .columnsTemplate('1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .width('100%')
              }

              // 时间和地点
              GlassmorphicCardDark({
                blurRadius: 15,
                cardOpacity: 0.2,
                cardBorderRadius: 16,
                cardPadding: 16
              }) {
                Column({ space: 12 }) {
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

      // 遮罩层（全屏时覆盖宫格）- 全黑渐变
      if (this.showOverlay) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(this.overlayOpacity)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }

      // 全屏预览层（Swiper 左右滑动）
      if (this.isFullscreen) {
        Stack() {
          // Swiper 放在最底层（最先添加，层级最低）
          Swiper() {
            ForEach(this.getImageUris(), (uri: string) => {
              OrientedImage({
                src: uri,
                objectFit: ImageFit.Contain
              })
                .width('100%')
                .height('100%')
            })
          }
          .index(this.currentImageIndex)
          .indicator(false)
          .loop(false)
          .onChange((index: number) => {
            this.currentImageIndex = index;
            // 同步更新动画位置到当前图片
            if (!this.isAnimating) {
              const screenWidth = 360;
              const screenHeight = 780;
              this.animImageX = 0;
              this.animImageY = 0;
              this.animImageWidth = screenWidth;
              this.animImageHeight = screenHeight;
            }
          })
          .width('100%')
          .height('100%')

          // 顶部可点击区域（后添加，层级在上，捕获顶部点击）
          Column()
            .width('100%')
            .height(120)
            .position({ top: 0 })
            .onClick((): void => {
              this.closeFullscreen();
            })

          // 底部可点击区域（后添加，层级在上，捕获底部点击）
          Column()
            .width('100%')
            .height(120)
            .position({ bottom: 0 })
            .onClick((): void => {
              this.closeFullscreen();
            })

          // 关闭按钮（最后添加，层级最高）
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
          .position({ top: 58, right: 16 })
          .onClick((): void => {
            this.closeFullscreen();
          })

          // 页码指示
          if (this.getImageUris().length > 1) {
            Row({ space: 8 }) {
              Text(`${this.currentImageIndex + 1} / ${this.getImageUris().length}`)
                .fontSize(16)
                .fontColor('#FFFFFF')
            }
            .position({ bottom: 60 })
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}

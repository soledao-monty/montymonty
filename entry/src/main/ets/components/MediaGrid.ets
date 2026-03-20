import { MediaItem } from '../model/MemoryCard';

@Component
export struct MediaGrid {
  @Prop mediaItems: string[] = [];
  @Prop columns: number = 3;
  @Prop spacing: number = 4;
  @Prop itemSize: number = 100;
  @Prop showAddButton: boolean = false;
  @Prop maxCount: number = 50;
  onAddClick?: () => void;
  onItemClick?: (index: number) => void;
  onItemRemove?: (index: number) => void;

  build() {
    Grid() {
      // 添加按钮
      if (this.showAddButton && this.mediaItems.length < this.maxCount) {
        GridItem() {
          Column() {
            Text('+')
              .fontSize(32)
              .fontColor('rgba(255, 255, 255, 0.6)')
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.1)')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .onClick((): void => {
          if (this.onAddClick) {
            this.onAddClick();
          }
        })
      }

      // 媒体项
      ForEach(this.mediaItems, (uri: string, index: number) => {
        GridItem() {
          Stack() {
            Image(uri)
              .width('100%')
              .height('100%')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            // 移除按钮
            if (this.onItemRemove) {
              Column() {
                Text('×')
                  .fontSize(20)
                  .fontColor('#FFFFFF')
              }
              .width(24)
              .height(24)
              .backgroundColor('rgba(0, 0, 0, 0.5)')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .position({ x: '85%', y: '5%' })
            }

            // 视频标识
            // if (isVideo) {
            //   Column() {
            //     Text('▶')
            //       .fontSize(16)
            //       .fontColor('#FFFFFF')
            //   }
            //   .width(32)
            //   .height(32)
            //   .backgroundColor('rgba(0, 0, 0, 0.5)')
            //   .borderRadius(16)
            //   .justifyContent(FlexAlign.Center)
            //   .alignItems(HorizontalAlign.Center)
            //   .position({ x: '50%', y: '50%' })
            //   .translate({ x: '-50%', y: '-50%' })
            // }
          }
          .width('100%')
          .height('100%')
        }
        .onClick((): void => {
          if (this.onItemClick) {
            this.onItemClick(index);
          }
        })
      })
    }
    .columnsTemplate('1fr '.repeat(this.columns).trim())
    .columnsGap(this.spacing)
    .rowsGap(this.spacing)
    .width('100%')
  }
}

/**
 * 紧凑型媒体网格（用于列表预览）
 */
@Component
export struct MediaGridCompact {
  @Prop mediaUris: string[] = [];
  @Prop count: number = 4;

  build() {
    Row({ space: 4 }) {
      ForEach(this.mediaUris.slice(0, this.count), (uri: string) => {
        Image(uri)
          .width(60)
          .height(60)
          .borderRadius(6)
          .objectFit(ImageFit.Cover)
      })

      // 更多照片标识
      if (this.mediaUris.length > this.count) {
        Column() {
          Text(`+${this.mediaUris.length - this.count}`)
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.8)')
        }
        .width(60)
        .height(60)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .borderRadius(6)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
  }
}

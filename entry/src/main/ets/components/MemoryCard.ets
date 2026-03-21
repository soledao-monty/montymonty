import { MemoryCard } from '../model/MemoryCard';
import { formatDate, formatRelativeTime } from '../utils/dateFormat';
import { GlassmorphicCard } from './GlassmorphicCard';
import { OrientedImage } from './OrientedImage';

@Component
export struct MemoryCardComponent {
  @Prop memory: MemoryCard;
  onCardClick?: () => void;

  build() {
    Column() {
      // 图片预览
      if (this.memory.mediaUris && this.memory.mediaUris.length > 0) {
        OrientedImage({
          src: this.memory.mediaUris[0],
          imgWidth: '100%',
          imgHeight: 180,
          radius: 16
        })
          .margin({ bottom: 12 })
      }

      // 描述文字
      Text(this.memory.description)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      // 时间和地点
      Row() {
        Text(formatRelativeTime(this.memory.timestamp))
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.7)')

        if (this.memory.location) {
          Text(' · ')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.7)')

          // 地点图标
          Row({ space: 3 }) {
            Text('📍')
              .fontSize(10)
            Text(this.memory.location)
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
      }
      .width('100%')

      // 照片数量
      if (this.memory.mediaUris && this.memory.mediaUris.length > 1) {
        Row() {
          Text(`${this.memory.mediaUris.length} 张照片`)
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.6)')
        }
        .width('100%')
        .margin({ top: 4 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .onClick((): void => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}

/**
 * 记忆卡片容器（带毛玻璃效果）
 */
@Component
export struct MemoryCardContainer {
  @Prop memory: MemoryCard;
  onCardClick?: () => void;

  build() {
    GlassmorphicCard({
      blurRadius: 15,
      cardOpacity: 0.25,
      cardBorderRadius: 20,
      cardPadding: 12
    }) {
      MemoryCardComponent({
        memory: this.memory,
        onCardClick: this.onCardClick
      })
    }
  }
}

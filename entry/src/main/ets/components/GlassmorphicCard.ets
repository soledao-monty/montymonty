@Component
export struct GlassmorphicCard {
  @Prop blurRadius: number = 20;
  @Prop cardOpacity: number = 0.2;
  @Prop cardBorderRadius: number = 24;
  @Prop cardPadding: number = 16;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content();
    }
    .padding(this.cardPadding)
    .width('100%')
    .backgroundColor(`rgba(255, 255, 255, ${this.cardOpacity})`)
    .backdropBlur(this.blurRadius)
    .borderRadius(this.cardBorderRadius)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.3)'
    })
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 10
    })
  }
}

/**
 * 暗色毛玻璃卡片
 */
@Component
export struct GlassmorphicCardDark {
  @Prop blurRadius: number = 20;
  @Prop cardOpacity: number = 0.3;
  @Prop cardBorderRadius: number = 24;
  @Prop cardPadding: number = 16;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content();
    }
    .padding(this.cardPadding)
    .width('100%')
    .backgroundColor(`rgba(0, 0, 0, ${this.cardOpacity})`)
    .backdropBlur(this.blurRadius)
    .borderRadius(this.cardBorderRadius)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.15)'
    })
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.3)',
      offsetX: 0,
      offsetY: 10
    })
  }
}

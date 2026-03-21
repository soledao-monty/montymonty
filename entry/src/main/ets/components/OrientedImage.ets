import image from '@ohos.multimedia.image';
import { mediaService } from '../services/MediaService';

@Component
export struct OrientedImage {
  @Prop src: string = '';
  @Prop imgWidth: string | number = '100%';
  @Prop imgHeight: string | number = '100%';
  @Prop radius: number = 0;
  @Prop objectFit: ImageFit = ImageFit.Cover;

  @State private pixelMap: image.PixelMap | null = null;
  @State private isLoading: boolean = true;

  async aboutToAppear() {
    if (this.src) {
      // 检查是否是视频
      const lowerSrc = this.src.toLowerCase();
      const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.m4v'];
      const isVideo = videoExtensions.some(ext => lowerSrc.endsWith(ext));

      if (!isVideo) {
        this.pixelMap = await mediaService.createOrientedPixelMap(this.src);
      }
      this.isLoading = false;
    }
  }

  build() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color('#FFFFFF')
      }
      .width(this.imgWidth)
      .height(this.imgHeight)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
    } else if (this.pixelMap) {
      Image(this.pixelMap)
        .width(this.imgWidth)
        .height(this.imgHeight)
        .borderRadius(this.radius)
        .objectFit(this.objectFit)
    } else {
      Image(this.src)
        .width(this.imgWidth)
        .height(this.imgHeight)
        .borderRadius(this.radius)
        .objectFit(this.objectFit)
    }
  }
}

import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

class MediaService {
  private context: common.Context | null = null;

  init(context: common.Context): void {
    this.context = context;
  }

  /**
   * 选择图片或视频
   */
  async selectMedia(maxCount: number = 50): Promise<string[]> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: maxCount,
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
      });

      if (result && result.photoUris) {
        return result.photoUris;
      }
      return [];
    } catch (err) {
      console.error('Failed to select media:', JSON.stringify(err));
      promptAction.showToast({
        message: '选择照片失败'
      });
      return [];
    }
  }

  /**
   * 创建正确方向的PixelMap
   */
  async createOrientedPixelMap(uri: string): Promise<image.PixelMap | null> {
    try {
      // 检查是否是视频
      const lowerUri = uri.toLowerCase();
      const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.m4v'];
      if (videoExtensions.some(ext => lowerUri.endsWith(ext))) {
        return null;
      }

      const imageSourceApi = image.createImageSource(uri);
      if (!imageSourceApi) {
        return null;
      }

      // 获取EXIF方向
      const orientationProperty = await imageSourceApi.getImageProperty(image.PropertyKey.ORIENTATION);
      const orientation = orientationProperty ? parseInt(orientationProperty) : 0;

      // 创建PixelMap
      const pixelMap = await imageSourceApi.createPixelMap();
      if (!pixelMap) {
        return null;
      }

      // 根据EXIF方向旋转
      let rotationAngle = 0;
      switch (orientation) {
        case 3: // 旋转180度
          rotationAngle = 180;
          break;
        case 6: // 顺时针旋转90度
          rotationAngle = 90;
          break;
        case 8: // 逆时针旋转90度
          rotationAngle = -90;
          break;
        default:
          return pixelMap;
      }

      // 旋转PixelMap
      await pixelMap.rotate(rotationAngle);
      return pixelMap;
    } catch (err) {
      console.error('Failed to create oriented pixel map:', JSON.stringify(err));
      return null;
    }
  }

  /**
   * 仅选择图片
   */
  async selectImages(maxCount: number = 50): Promise<string[]> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: maxCount,
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      });

      if (result && result.photoUris) {
        return result.photoUris;
      }
      return [];
    } catch (err) {
      console.error('Failed to select images:', JSON.stringify(err));
      promptAction.showToast({
        message: '选择照片失败'
      });
      return [];
    }
  }

  /**
   * 仅选择视频
   */
  async selectVideos(maxCount: number = 50): Promise<string[]> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: maxCount,
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE
      });

      if (result && result.photoUris) {
        return result.photoUris;
      }
      return [];
    } catch (err) {
      console.error('Failed to select videos:', JSON.stringify(err));
      promptAction.showToast({
        message: '选择视频失败'
      });
      return [];
    }
  }
}

export const mediaService = new MediaService();

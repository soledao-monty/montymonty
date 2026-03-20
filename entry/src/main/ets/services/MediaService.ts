import photoAccessHelper from '@ohos.file.photoAccessHelper';
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

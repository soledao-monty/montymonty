import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';

class LocationService {
  /**
   * 获取当前位置
   */
  async getCurrentLocation(): Promise<string> {
    try {
      const location = geoLocationManager.getCurrentLocation();
      // 这里简化处理，实际需要通过逆地理编码获取地名
      // 可以集成地图服务的逆地理编码API
      return location ? '当前位置' : '';
    } catch (err) {
      console.error('Failed to get location:', JSON.stringify(err));
      promptAction.showToast({
        message: '获取位置失败'
      });
      return '';
    }
  }

  /**
   * 逆地理编码（需要地图服务支持）
   * 简化版本返回坐标
   */
  async reverseGeocode(latitude: number, longitude: number): Promise<string> {
    // HarmonyOS 逆地理编码需要额外配置
    // 这里返回简化信息
    return `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`;
  }
}

export const locationService = new LocationService();

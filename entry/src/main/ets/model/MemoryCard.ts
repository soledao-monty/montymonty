/**
 * 回忆卡片数据模型
 */
export interface MemoryCard {
  id: string;
  description: string;
  timestamp: number;
  location: string;
  mediaUris: string[];
  createdAt: number;
  updatedAt: number;
}

/**
 * 媒体类型
 */
export interface MediaItem {
  uri: string;
  type: 'image' | 'video';
  duration?: number;
}

/**
 * 数据库行类型
 */
export interface MemoryCardRow {
  id: string;
  description: string;
  timestamp: number;
  location: string;
  mediaUris: string;
  createdAt: number;
  updatedAt: number;
}

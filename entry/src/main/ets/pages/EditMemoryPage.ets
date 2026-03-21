import { router, promptAction } from '@kit.ArkUI';
import { storageService } from '../services/StorageService';
import { mediaService } from '../services/MediaService';
import { MemoryCard } from '../model/MemoryCard';
import { GlassmorphicCardDark } from '../components/GlassmorphicCard';
import { MediaGrid } from '../components/MediaGrid';

@Entry
@Component
struct EditMemoryPage {
  @State memoryId: string = '';
  @State description: string = '';
  @State timestamp: number = Date.now();
  @State location: string = '';
  @State mediaUris: string[] = [];
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;

  // 日期选择
  private selectedDate: Date = new Date();
  // 时间选择
  private selectedHour: number = new Date().getHours();
  private selectedMinute: number = new Date().getMinutes();

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.memoryId = params?.memoryId || '';

    if (this.memoryId) {
      try {
        const memory = await storageService.queryById(this.memoryId);
        if (memory) {
          this.description = memory.description;
          this.timestamp = memory.timestamp;
          this.location = memory.location;
          this.mediaUris = [...memory.mediaUris];

          const date = new Date(this.timestamp);
          this.selectedHour = date.getHours();
          this.selectedMinute = date.getMinutes();
        }
      } catch (err) {
        console.error('Failed to load memory:', JSON.stringify(err));
        promptAction.showToast({ message: '加载回忆失败' });
      }
    }
    this.isLoading = false;
  }

  async saveMemory() {
    // 验证
    if (!this.description.trim()) {
      promptAction.showToast({ message: '请输入回忆描述' });
      return;
    }
    if (this.mediaUris.length === 0) {
      promptAction.showToast({ message: '请选择至少一张照片' });
      return;
    }

    this.isSaving = true;

    try {
      const memory: MemoryCard = {
        id: this.memoryId,
        description: this.description.trim(),
        timestamp: this.timestamp,
        location: this.location.trim(),
        mediaUris: this.mediaUris,
        createdAt: Date.now(), // 保留原始创建时间
        updatedAt: Date.now()
      };

      await storageService.update(memory);
      promptAction.showToast({ message: '保存成功' });

      // 返回详情页
      router.back();
    } catch (err) {
      console.error('Failed to save memory:', JSON.stringify(err));
      promptAction.showToast({ message: '保存失败' });
    } finally {
      this.isSaving = false;
    }
  }

  async selectPhotos() {
    const uris = await mediaService.selectMedia(50 - this.mediaUris.length);
    if (uris.length > 0) {
      this.mediaUris = [...this.mediaUris, ...uris];
    }
  }

  removePhoto(index: number) {
    this.mediaUris = this.mediaUris.filter((_, i) => i !== index);
  }

  formatDisplayDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hour = date.getHours();
    const minute = date.getMinutes();
    return `${year}年${month}月${day}日 ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  }

  openDatePicker() {
    DatePickerDialog.show({
      start: new Date('1900-1-1'),
      end: new Date(),
      selected: new Date(this.timestamp),
      onAccept: (value) => {
        const date = new Date(this.timestamp);
        date.setFullYear(value.year, value.month, value.day);
        this.timestamp = date.getTime();
        // 日期选择后弹出时间选择
        setTimeout(() => {
          this.openTimePicker();
        }, 300);
      }
    })
  }

  openTimePicker() {
    TimePickerDialog.show({
      start: new Date(0, 0, 0, 0, 0),
      end: new Date(0, 0, 0, 23, 59),
      selected: new Date(0, 0, 0, this.selectedHour, this.selectedMinute),
      useMilitaryTime: false,
      onAccept: (value) => {
        const date = new Date(this.timestamp);
        date.setHours(value.hour, value.minute);
        this.timestamp = date.getTime();
        this.selectedHour = value.hour;
        this.selectedMinute = value.minute;
      }
    })
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color('#FFFFFF')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 顶部导航
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.7)')
            .onClick((): void => {
              router.back();
            })

          Text('编辑回忆')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')

          Text(this.isSaving ? '保存中...' : '保存')
            .fontSize(16)
            .fontColor(this.isSaving ? 'rgba(255, 255, 255, 0.4)' : '#FFFFFF')
            .onClick((): void => {
              if (!this.isSaving) {
                this.saveMemory();
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll() {
          Column({ space: 20 }) {
            // 文字描述
            GlassmorphicCardDark({
              blurRadius: 15,
              cardOpacity: 0.2,
              cardBorderRadius: 16,
              cardPadding: 16
            }) {
              Column({ space: 8 }) {
                Text('这一刻的感受')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.6)')
                  .margin({ bottom: 8 })

                TextArea({
                  placeholder: '写下这一刻的感受...',
                  text: this.description
                })
                  .placeholderColor('rgba(255, 255, 255, 0.4)')
                  .caretColor('#FFFFFF')
                  .fontColor('#FFFFFF')
                  .fontSize(16)
                  .width('100%')
                  .height(100)
                  .backgroundColor(Color.Transparent)
                  .onChange((value: string): void => {
                    this.description = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            // 时间和地点
            GlassmorphicCardDark({
              blurRadius: 15,
              cardOpacity: 0.2,
              cardBorderRadius: 16,
              cardPadding: 16
            }) {
              Column({ space: 16 }) {
                // 时间选择
                Row() {
                  Column({ space: 8 }) {
                    Text('时间')
                      .fontSize(14)
                      .fontColor('rgba(255, 255, 255, 0.6)')
                    Text(this.formatDisplayDate(this.timestamp))
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Text('修改')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                    .onClick((): void => {
                      this.openDatePicker();
                    })
                }
                .width('100%')

                Divider()
                  .color('rgba(255, 255, 255, 0.1)')

                // 地点输入
                Column({ space: 8 }) {
                  Text('地点')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                    .margin({ bottom: 8 })

                  TextInput({
                    placeholder: '在哪里？',
                    text: this.location
                  })
                    .placeholderColor('rgba(255, 255, 255, 0.4)')
                    .caretColor('#FFFFFF')
                    .fontColor('#FFFFFF')
                    .fontSize(16)
                    .width('100%')
                    .backgroundColor(Color.Transparent)
                    .onChange((value: string): void => {
                      this.location = value;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }

            // 照片选择
            GlassmorphicCardDark({
              blurRadius: 15,
              cardOpacity: 0.2,
              cardBorderRadius: 16,
              cardPadding: 16
            }) {
              Column({ space: 12 }) {
                Row() {
                  Text('照片')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.6)')

                  if (this.mediaUris.length > 0) {
                    Text(`${this.mediaUris.length} / 50`)
                      .fontSize(14)
                      .fontColor('rgba(255, 255, 255, 0.6)')
                  }
                }

                if (this.mediaUris.length > 0) {
                  MediaGrid({
                    mediaItems: this.mediaUris,
                    columns: 3,
                    spacing: 8,
                    showAddButton: true,
                    maxCount: 50,
                    onAddClick: (): void => {
                      this.selectPhotos();
                    },
                    onItemRemove: (index: number): void => this.removePhoto(index)
                  })
                } else {
                  Column() {
                    Text('+')
                      .fontSize(40)
                      .fontColor('rgba(255, 255, 255, 0.4)')
                    Text('点击添加照片')
                      .fontSize(14)
                      .fontColor('rgba(255, 255, 255, 0.4)')
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .height(120)
                  .backgroundColor('rgba(255, 255, 255, 0.05)')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => {
                    this.selectPhotos();
                  })
                }
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
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

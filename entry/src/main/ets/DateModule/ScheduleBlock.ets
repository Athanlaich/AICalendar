import { Schedule } from './agendaStruct' // 引入 Schedule 类
import { theTime } from './theTime'
import { TodoInfoDialog } from './TodoInfoDialog' //日程信息弹窗

@Component
export struct ScheduleBlock {
  @Prop schedule: Schedule  // 接收要显示的日程对象
  @State ExistInDB:Boolean=false  //记录该日程是否在数据库中存在
  private TodoInfoDialog: CustomDialogController = new CustomDialogController({
    builder: TodoInfoDialog({
      schedule: this.schedule,   //传入日程块的信息
    })
  })

  build() {
    Row() {
      Column() {
        Text(this.schedule.title)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.schedule.color)
      .borderRadius(5)
      .onClick(() => {
        this.TodoInfoDialog.open()   //打开信息弹窗
      })
    }
    .width('100%')
    .padding(1)
    .position({ y: this.calculateYPosition(this.schedule.start)}) // 调整Y轴位置
    .height(this.calculateHeight(this.schedule.start, this.schedule.end)) // 调整高度
    .transition({ type: TransitionType.Delete, opacity: 0, scale: { x: 0, y: 0 } })
    //}
  }

  // 计算日程块的垂直位置，映射到页面高度
  calculateYPosition(time: string): number {
    const totalMinutesInDay = 24 * 60; // 一天的总分钟数
    const pageHeight = 24 * 60; // 页面高度应设置为1440（24小时*60分钟）
    const positionInMinutes = theTime.hhmm2position(time); // 计算从00:00到指定时间的分钟数
    const yPosition = (positionInMinutes / totalMinutesInDay) * pageHeight; // 将分钟数映射到页面高度
    return yPosition; // 返回 Y 轴位置
  }

  // 计算日程块的高度
  calculateHeight(start: string, end: string): number {
    const totalMinutesInDay = 24 * 60;
    const pageHeight = 24 * 60;
    const duration = theTime.getDuration(start, end); // 获取两个时间之间的时长（分钟数）
    return (duration / totalMinutesInDay) * pageHeight; // 将时长映射到页面高度
  }
}



import promptAction from '@ohos.promptAction'
import { theTime } from './theTime'

@Component
export struct TimeSelector {
  @Link selectedTime: string
  @State timePressed: boolean = false // 记录时间选择器的按下状态
  dialogController: CustomDialogController = new CustomDialogController({
    builder: TimeSelectDialog({selectedTime: $selectedTime}),
  })

  build() {
    Row() {
      Text(this.selectedTime)
        .fontSize(20)
    }
    .border({ width: 1, color: Color.Gray, radius: "8" })
    .backgroundColor(this.timePressed ? '#d3d3d3' : Color.White)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.timePressed = true // 按下时设置为 true
      } else if (event.type === TouchType.Up) {
        this.timePressed = false // 松开时恢复为 false
      }
    })
    .onClick((event: ClickEvent) => {
      this.dialogController.open()
    })
  }
}

@CustomDialog
struct TimeSelectDialog {
  @Link selectedTime: string
  private selectingTime: Date = new Date("1000-01-01 " + this.selectedTime)
  controller: CustomDialogController
  build() {
    TimePicker({selected:this.selectingTime})
      .onChange((value:TimePickerResult) => {
        this.selectingTime.setHours(value.hour, value.minute, 0, 0)
      })
      .useMilitaryTime(true)
      .onDisAppear(()=>{
        this.selectedTime = theTime.date2hhmm(this.selectingTime)
      })
  }
}
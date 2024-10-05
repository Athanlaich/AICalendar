import promptAction from '@ohos.promptAction'
import { theDate } from './theDate'

@Component
export struct DateSelector {
  @Link selectedDate: string
  @State datePressed: boolean = false // 记录日期选择器的按下状态
  onDialogDisappear:()=>void = ()=>{}
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DateSelectDialog({selectedDate: $selectedDate}),
    cancel:()=>{this.onDialogDisappear()}
  })

  build() {
    Row() {
      Text(this.selectedDate)
        .fontSize(20)
      /*Image($r("app.media.down"))
        .width(15)
        .height(15)*/
    }
    .border({ width: 1, color: Color.Gray, radius: "8" })
    .backgroundColor(this.datePressed ? '#d3d3d3' : Color.White)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.datePressed = true // 按下时设置为 true
      } else if (event.type === TouchType.Up) {
        this.datePressed = false // 松开时恢复为 false
      }
    })
    .onClick((event: ClickEvent) => {
      this.dialogController.open()
    })
  }
}

@CustomDialog
struct DateSelectDialog {
  @Link selectedDate: string
  private selectingDate: Date = new Date(this.selectedDate)
  controller: CustomDialogController
  build() {
    DatePicker({start:new Date('2000-09-01'),
      selected:this.selectingDate,
      end:new Date('2100-09-01')})
      .onChange((value:DatePickerResult) => {
        this.selectingDate.setFullYear(value.year as number, value.month as number, value.day as number)
      })
      .onDisAppear(()=>{
        this.selectedDate = theDate.date2yyyyMMDD(this.selectingDate)
      })
  }
}
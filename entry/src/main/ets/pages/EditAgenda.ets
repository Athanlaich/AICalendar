import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { DateSelector } from '../DateModule/DatePicker'
import { TimeSelector } from '../DateModule/TimePicker'
import { theDate } from '../DateModule/theDate'
import { theTime } from '../DateModule/theTime'
import relationalStore from '@ohos.data.relationalStore'
import emitter from '@ohos.events.emitter'
import { ValuesBucket } from '@ohos.data.ValuesBucket'
import { GlobalContext } from '../GlobalContext/GlobalContext'
import { Schedule } from '../DateModule/agendaStruct'

@Entry
@Component
struct EditAgenda {
  ID: number = 0
  @State title: string = ''
  @State description: string = ''
  @State place: string = ''
  @State date: string = theDate.today()
  @State start: string = theTime.now()
  @State end: string = theTime.now()
  @State color: string = Schedule.COLORS[0]


  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number>;
    if (params) {
      this.ID = params.ID as number || 0
      this.title = params.title as string || ''
      this.description = params.description as string || ''
      this.place = params.place as string || ''
      this.color = params['color'] as string
      this.date = params.date as string || theDate.today() // 如果没有提供日期参数，则使用今天的日期
      this.start = params.start as string || theTime.now() // 如果没有提供开始时间，则使用当前时间
      this.end = params.end as string || theTime.now() // 如果没有提供结束时间，则使用当前时间
    } else {
      console.warn('No parameters found, using default values')
    }
  }

  build() {
    Column({ space: 30 }) {
      Row() {
        Text('编辑日程')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({left:20})
      }
      .width('100%').height('7%').backgroundColor('#89AFE0')
      //Divider().strokeWidth(2).color('#F1F3F5').lineCap(LineCapStyle.Round) //分割线
      Row({ space: 5 }) {
        Image($r('app.media.name'))
          .margin({ left: 20 })
          .layoutWeight(15)
          .alignSelf(ItemAlign.Start)
          .interpolation(ImageInterpolation.High)
          .height(30)
          .objectFit(ImageFit.Contain)
        TextInput({ placeholder: '请输入日程名称', text: this.title })
          .layoutWeight(80)
          .margin({ right: 20 })
          .onChange((value: string) => {
            this.title = value
          })
      }

      Row({ space: 5 }) {
        Image($r('app.media.description'))
          .margin({ left: 20 })
          .layoutWeight(15)
          .alignSelf(ItemAlign.Start)
          .interpolation(ImageInterpolation.High)
          .height(30)
          .objectFit(ImageFit.Contain)
        TextArea({ placeholder: '请描述该日程（选填）', text: this.description })
          .layoutWeight(80)
          .margin({ right: 20 })
          .height(100)
          .onChange((value: string) => {
            this.description = value
          })
      }

      Row({ space: 5 }) {
        Image($r('app.media.place'))
          .margin({ left: 20 })
          .layoutWeight(15)
          .alignSelf(ItemAlign.Start)
          .interpolation(ImageInterpolation.High)
          .height(30)
          .objectFit(ImageFit.Contain)
        TextInput({ placeholder: '请输入日程地点（选填）', text: this.place })
          .layoutWeight(80)
          .margin({ right: 20 })
          .onChange((value: string) => {
            this.place = value
          })
      }

      Row({ space: 10 }) {
        Text('日期:')
          .margin({ left: 20 })
          .fontSize(20)
          .layoutWeight(20)
          .alignSelf(ItemAlign.Start)
          .fontWeight(FontWeight.Bold)
        DateSelector({ selectedDate: $date })
          .layoutWeight(80)
      }

      Row({ space: 10 }) {
        Text('时间:')
          .margin({ left: 20 })
          .layoutWeight(20)
          .fontSize(20)
          .alignSelf(ItemAlign.Start)
          .fontWeight(FontWeight.Bold)
        Row() {
          TimeSelector({ selectedTime: $start })
          Text(' — ')
          TimeSelector({ selectedTime: $end })
        }
        .layoutWeight(80)
      }
      Row() {
        Text('颜色:')
          .margin({left:20})
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
          .layoutWeight(20)
        Row() {
          ForEach(Schedule.COLORS, (item:string, index:number)=>{
            Circle()
              .width(this.color == item ? 40 : 20)
              .animation({duration:1000, curve:Curve.Ease})
              .aspectRatio(1)
              .fill(item)
              .onClick(()=>{
                this.color = item
              })
          })
        }
        .justifyContent(FlexAlign.SpaceAround)
        .layoutWeight(80)
        .margin({right:20})
      }
      .height(40)

      Blank(150)
      Row() {
        Button('取消')
          .width(80)
          .height(40)
          .margin({ left: 20 })
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Red)
          .onClick(() => {
            router.back()
          })
        Blank(100)
        Button('确认')
          .width(80)
          .height(40)
          .margin({ right: 20 })
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Green)
          .onClick(() => {
            this.onSubmit()
          })
      }
    }
    .width('100%')
  }

  //提交日程的函数
  private onSubmit(): void {
    if (this.title == '') {
      promptAction.showToast({ message: '标题不能为空！', bottom: 200 })
      return
    }
    if (theTime.getHours(this.start) > theTime.getHours(this.end) || (theTime.getHours(this.start)==theTime.getHours(this.end) && theTime.getMinutes(this.start)>=theTime.getMinutes(this.end)) ) {
      promptAction.showToast({ message: '时间不正确!', bottom: 200 })
      return
    }

    //const store: relationalStore.RdbStore = globalThis.store
    const store: relationalStore.RdbStore = GlobalContext.getInstance().getStore() as relationalStore.RdbStore;
    if (!store || !store.update) {  //如果store未初始化或 update 方法不可用，打印错误信息并结束函数执行
      console.error('Store is not initialized or update method is not available.');
      return;
    }

    //要存储的日程数据
    const valueBucket: ValuesBucket = {
      'TITLE': this.title,
      'DESCRIPTION': this.description,
      'PLACE': this.place,
      'DATE': this.date,
      'START': this.start,
      'END': this.end,
      'COLOR': this.color
    }

    //检查日程是否冲突
    this.checkScheduleConflict(store,this.ID,this.date,this.start,this.end)
      .then(conflict => {
        if (conflict) {
          console.log("存在冲突的日程，不可插入");
          promptAction.showToast({ message: '与其他日程时间相冲突，不可创建！', bottom: 200 })
          return
        } else {
          console.log("可以插入新日程");
          //下面新建或编辑日程
          if (this.ID == 0) { //新建
            //将 valueBucket 插入到数据库的 SCHEDULES 表中
            store.insert('SCHEDULES', valueBucket, (err, rowId) => {
              if (err) {
                console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`)
                return
              }
              console.info(`Succeeded in inserting data. rowId:${rowId}`)  //rowId唯一地标识表中的一行记录
              emitter.emit({ eventId: 0 })
              router.back()
            })
          } else{ //编辑(已有的日程)
            const predicates = new relationalStore.RdbPredicates('SCHEDULES')
            predicates.equalTo('ID', this.ID)   //查询条件predicates，指定要更新的某条记录的ID
            store.update(valueBucket, predicates, (err, rowId) => {
              if (err) {
                console.error(`Failed to update data. Code:${err.code}, message:${err.message}`);
                return;
              }
              console.info(`Succeeded in updating data. rowId:${rowId}`);
              emitter.emit({ eventId: 0 });
              router.back();
            })
          }
        }
      })


  }

  //检查日程是否冲突
  async checkScheduleConflict(store: relationalStore.RdbStore, id:number, date:string,startTime:string, endTime:string): Promise<boolean> {
    //查询条件
    let query = "SELECT * FROM SCHEDULES WHERE (date == ? ) AND (ID!= ?) AND ((start <= ? AND ? < end) OR (start < ? AND ? <= end) OR (? <= start AND end <= ?))";  //冲突的三种条件
    //查询参数
    let params = [date,id,startTime,startTime,endTime,endTime,startTime,endTime];
    try {
      // 执行查询并等待结果
      let result = await store.querySql(query, params);
      // 检查结果
      return result.rowCount > 0;  //则冲突
    } catch (error) {
      console.error("查询出错:", error);
      return false;
    }
  }
}
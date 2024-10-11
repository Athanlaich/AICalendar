import router from '@ohos.router' // 路由模块，用于页面导航
import promptAction from '@ohos.promptAction'
import relationalStore from '@ohos.data.relationalStore'
import { Schedule } from './agendaStruct'
import { GlobalContext } from '../GlobalContext/GlobalContext'
import emitter from '@ohos.events.emitter'

@CustomDialog
export struct TodoInfoDialog { //日程信息弹窗
  InfoDialogController: CustomDialogController //弹窗控制器，控制打开/关闭
  @Prop schedule: Schedule

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Auto, justifyContent: FlexAlign.Start }) {
      //日程名称和功能键
      Row() {
        Text(this.schedule.title)//名称
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .width('70%')
          .margin({ left: 25 })
        Image($r('app.media.delete'))//删除
          .width('10%')
          .height(35)
          .interpolation(ImageInterpolation.High)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            promptAction.showDialog({
              title: "是否删除该日程？",
              buttons: [
                {
                  text: '否',
                  color: '#000000',
                },
                {
                  text: '是',
                  color: '#000000',
                }
              ]
            })
              .then((value: promptAction.ShowDialogSuccessResponse) => { //按钮的点击事件
                switch (value.index) {
                  case 0: //点击否
                    break
                  case 1: //点击是，删除该日程
                    const store: relationalStore.RdbStore =
                      GlobalContext.getInstance().getStore() as relationalStore.RdbStore;
                    const predicates = new relationalStore.RdbPredicates('SCHEDULES')
                    predicates.equalTo('ID', this.schedule.ID)
                    store.delete(predicates)
                      .then(() => {
                        this.InfoDialogController.close()
                        //this.onDelete()
                        emitter.emit({ eventId: 0 }); //通知页面更新
                        console.warn(`已删除ID为${this.schedule.ID}的日程！`)
                      })
                    break
                }
              })
          })
        Image($r('app.media.edit'))//编辑
          .width('16%')
          .height(35)
          .interpolation(ImageInterpolation.High)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/EditAgenda',
              params: this.schedule
            })
          })
      }.height(75).backgroundColor(this.schedule.color)

      //日期
      Row() {
        Text(`日期: ${this.schedule.date}`)//可不要
          .fontSize(20)
          .margin({ left: 25 })
      }.height(30)

      //时间
      Row() {
        Text(`时间: ${this.schedule.start} ~ ${this.schedule.end}`)
          .fontSize(20)
          .margin({ left: 25 })
      }.height(30)

      //地点
      Row() {
        Text(`地点: ${this.schedule.place || '无'}`)
          .fontSize(20)
          .margin({ left: 25 })
      }.height(30)

      //备注
      Row() {
        Text(`备注: ${this.schedule.description || '无'}`)
          .fontSize(20)
          .margin({ left: 25 })
      }.height(30)
    }
    .width('100%')
    .height('50%')
  }
}

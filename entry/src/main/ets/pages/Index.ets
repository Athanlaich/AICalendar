import { theDate } from '../DateModule/theDate'
import { theTime } from '../DateModule/theTime'
import router from '@ohos.router'; // 路由模块，用于页面导航
import { Schedule } from '../DateModule/agendaStruct'; // 引入 Schedule 类
import { ScheduleColumn } from '../DateModule/ScheduleColumn'
import notificationManager from '@ohos.notificationManager'
import WantAgent from '@ohos.app.ability.wantAgent'
import Want from '@ohos.app.ability.Want'
import common from '@ohos.app.ability.common'
import pasteboard from '@ohos.pasteboard'
import { Reminder } from '../aiability/Reminder'
import relationalStore from '@ohos.data.relationalStore'
import { GlobalContext } from '../GlobalContext/GlobalContext'
import promptAction from '@ohos.promptAction'
import  { BusinessError }  from '@ohos.base'
import emitter from '@ohos.events.emitter'

@Entry
@Component
struct Index {
  @State date: string = theDate.today() //今天日期
  @State schedules: Schedule[] = [] // 存储从数据库中加载的日程列表
  enterFromRight: boolean = true // 页面进场动画方向（从右侧进入）
  exitToRight: boolean = false // 页面离场动画方向（向右侧离开）
  @State addBtnPressed: boolean = false // 跟踪添加按钮的按下状态
  @State moreBtnPressed: boolean = false // 跟踪更多按钮的按下状态
  @State offsetX: number = 0 // 控制滑动时内容的水平偏移量
  @State isSliding: boolean = false // 用于跟踪是否正在滑动
  reminder: Reminder = new Reminder();

  //菜单
  @Builder
  MyMenu() {
    Menu() {
      MenuItem({ startIcon: $r("app.media.kimi"), content: "智能助手" })
        .onClick(() => {
          router.pushUrl({ url: 'pages/kimi' }) // 跳转到智能助手kimi页面
        })
      MenuItem({ startIcon: $r("app.media.clean"), content: "一键删除" })
      .onClick(() => {
          return ActionSheet.show({
            title: '一键删除',
            message: '请选择你将对日程表进行的删除操作：',
            autoCancel: true,
            confirm: {  //底部按钮
              value: '取消',
              action: () => {
                console.log('取消一键删除操作')
              }
            },
            cancel: () => {},    //屏障层取消
            alignment: DialogAlignment.Center,
            offset: { dx: 0, dy: -10 },
            sheets: [  //操作列表
              {
                icon:$r('app.media.one'),
                title: "删除今天的所有日程",
                action: () => {
                  this.deleteSchedule(1)
                  console.warn(`今天（${this.date}）的所有日程被删除！`)
                  promptAction.showToast({ message: `今天（${this.date}）的所有日程被删除！`, bottom: 310 })
                }
              },
              {
                icon:$r('app.media.two'),
                title: "删除日程表中的所有日程",
                action: () => {
                  this.deleteSchedule(2)
                  console.warn(`日程表中所有日程被删除！`)
                  promptAction.showToast({ message: `日程表中所有日程被删除！`, bottom: 310 })
                }
              }
            ]
          })
        })
    }
  }

  // 请求通知授权
  async requestNotificationPermission() {
    let context = getContext(this) as common.UIAbilityContext;
    try {
      const isEnabled = await notificationManager.isNotificationEnabled();
      console.info("isNotificationEnabled success, data: " + JSON.stringify(isEnabled));

      if (!isEnabled) {
        await notificationManager.requestEnableNotification(context);
        console.info(`[ANS] requestEnableNotification success`);
        this.publishNotification();
      }
    } catch (err) {
      console.error(`isNotificationEnabled fail: ${JSON.stringify(err)}`);
    }
  }

  //通知栏显示
  async publishNotification() {
    //WantAgentInfo对象
    let wantAgentInfo: WantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.ai_calendar", // 自己应用的bundleName
          abilityName: "AIAbility",
        } as Want
      ],
      operationType: WantAgent.OperationType.START_ABILITIES,
      requestCode: 1,
    }
    try {
      console.log("Publishing notification...");
      const agent = await WantAgent.getWantAgent(wantAgentInfo);
      console.log("Got WantAgent:", agent);
      await notificationManager.publish({
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: "AI_Calendar",
            text: "请点击输入日程信息"
          }

        },

        id: 1,
        isUnremovable: false,
        tapDismissed: false,
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        wantAgent: agent
      });
      console.log("Notification published successfully.");
    } catch (error) {
      console.error("Error publishing notification:", error);
    }
  }

  // 页面即将显示时执行的方法
  async aboutToAppear() {
    const params = router.getParams() as Record<string, string | boolean>; // 从路由中获取参数
    if (typeof params !== 'undefined') {
      this.date = params.date as string // 更新当前显示的日期
      this.enterFromRight = params.enterFromRight as boolean // 更新进场动画方向
    }
    this.requestNotificationPermission(); // 请求通知权限
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    let listener = () => {
      console.info('The system pasteboard has changed.');
      this.publishNotification();
    };
    systemPasteboard.on('update', listener);
    ////////////////////////////////
    setInterval(() => {
      this.reminder.checkReminders(this.date);
    }, 180000);
  }

  build() {
    Column() { // 使用 Column 布局
      Row() { // 导航栏
        Text('我的日程')// 导航栏左侧文字
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({
            top: '0.00px',
            right: '0.00px',
            bottom: '0.00px',
            left: '10.00vp'
          })
          .align(Alignment.Center)
          .width('40.00%')
          .alignSelf(ItemAlign.Center)
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.NoWrap,
          justifyContent: FlexAlign.End,
          alignItems: ItemAlign.Center
        }) {
          Button({ type: ButtonType.Circle }) { // 添加日程按钮
            Image($r("app.media.add"))
              .width('30.00vp')
              .height(30)
          }
          .padding(3)
          .height('35.00vp')
          .margin({ right: 20 })
          .backgroundColor(this.addBtnPressed ? '#d3d3d3' : Color.White)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.addBtnPressed = true // 按下时设置为 true
            } else if (event.type === TouchType.Up) {
              this.addBtnPressed = false // 松开时恢复为 false
            }
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/EditAgenda', params: { date: this.date } }) // 跳转到添加日程页面
          })
          .margin({
            top: '0.00px',
            right: '40.00vp',
            bottom: '0.00px',
            left: '0.00px'
          })
          .width('35vp')

          Button({ type: ButtonType.Circle }) { // 更多功能按钮
            Image($r("app.media.more"))
              .width(30)
              .height(30)
          }
          .padding(3)
          .height(35)
          .margin({
            top: '0.00px',
            right: '30.00vp',
            bottom: '0.00px',
            left: '0.00px'
          })
          .backgroundColor(this.moreBtnPressed ? '#d3d3d3' : Color.White)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.moreBtnPressed = true // 按下时设置为 true
            } else if (event.type === TouchType.Up) {
              this.moreBtnPressed = false // 松开时恢复为 false
            }
          })
          .bindMenu(this.MyMenu)
        }
        .width('60.00%')
      }
      .width('100%').height('7%').backgroundColor('#CAF4FF').padding(10)

      Row() {
        Text(theDate.getMonth(theDate.daysInTheSameWeek(this.date)[0]) + '\n月')
          .width('11.00%')
          .fontSize(16)
          .padding(10)
        ForEach(theDate.daysInTheSameWeek(this.date), (item: string, index: number) => {
          this.DateTitle(item)
        })
      }
      .width('100%')
      .height('10%')

      Divider()

      // 日程内容部分 - 加入滑动效果
      Row() {
        Scroll() {
          Column() {
            Row() {
              Column() {
                ForEach(theTime.HOURS, (item: string, index: number) => {
                  Column() {
                    Divider()
                    Text(item + ':00')
                      .fontSize(14)
                      .margin({ top: 0, bottom: 0 })
                  }
                  .justifyContent(FlexAlign.Start)
                  .margin({ top: 0, bottom: 0 })
                })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width(40)
              .height('100%')

              ForEach(theDate.daysInTheSameWeek(this.date), (item: string, index: number) => {
                ScheduleColumn({ date: item })// 渲染每一天的日程列
                  .layoutWeight(1)
              })
            }
            .width('100%')
            .height(24 * 60) // 设置为24小时的分钟数
            .margin({ top: 0 }) // 移除默认的marginTop
          }
          .offset({ x: this.offsetX }) // 使用 offset 控制水平位移
        }
        .width('100%')

      }
      .height('93%')
      // 滑动手势处理
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionUpdate((event: GestureEvent) => {
            this.isSliding = true
            this.offsetX = event.offsetX // 根据手势的位移更新 offsetX
          })
          .onActionEnd((event: GestureEvent) => {
            this.isSliding = false
            // 判断滑动的方向，决定切换到哪一周
            if (this.offsetX > 100) {
              // 如果右滑距离大于100，切换到上一周
              this.date = theDate.dateWithOffset(this.date, -7)
            } else if (this.offsetX < -100) {
              // 如果左滑距离大于100，切换到下一周
              this.date = theDate.dateWithOffset(this.date, 7)
            }
            this.offsetX = 0 // 重置偏移量
          })
      )
    }
  }

  // 页面进场和离场动画
  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 250 })// 进场动画
      .slide(this.enterFromRight ? SlideEffect.Right : SlideEffect.Left)// 根据方向设置滑动效果
      .onEnter((type: RouteType, progress: number) => {
        if (progress > 0.99) {
          router.clear() // 动画完成后清除路由历史
        }
      })
    PageTransitionExit({ type: RouteType.Push, duration: 250 })// 离场动画
      .slide(this.exitToRight ? SlideEffect.Right : SlideEffect.Left) // 根据方向设置滑动效果
  }

  // 渲染每一天的标题
  @Builder
  DateTitle(date: string) {
    Column() {
      Text(theDate.WEEKDAYS[theDate.getDay(date)])// 显示星期几
        .fontSize(14)
        .fontColor(theDate.isToday(date) ? Color.Black : Color.Gray) // 如果是今天，则字体颜色为黑色，否则为灰色
        .fontWeight(theDate.isToday(date) ? FontWeight.Bold : FontWeight.Normal)
      Text(theDate.getDate(date) + '日')// 显示日期
        .fontSize(14)
        .fontColor(theDate.isToday(date) ? Color.Black : Color.Gray) // 如果是今天，则字体颜色为黑色，否则为灰色
        .fontWeight(theDate.isToday(date) ? FontWeight.Bold : FontWeight.Normal)
    }
    .layoutWeight(1) // 布局权重
  }
  //删除日程函数
  deleteSchedule(choice:number,callback?:()=>void):void {
    const store: relationalStore.RdbStore = GlobalContext.getInstance().getStore() as relationalStore.RdbStore;
    if (!store || !store.update) {  //如果store未初始化或 update 方法不可用，打印错误信息并结束函数执行
      console.error('Store is not initialized or update method is not available.');
    }
    if(choice == 1){
      //查询条件
      let query = "DELETE FROM SCHEDULES WHERE ( date == ? ) ;"   //删除今天日程
      //查询参数
      let params = [this.date];
      store.executeSql(query, params)
        .then(() => {
          console.info('Delete done.');
          emitter.emit({ eventId: 0 });   //发送事件，通知其他页面更新
        }).catch((err: BusinessError) => {
        console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }else if(choice == 2){
      let query = "DELETE FROM SCHEDULES " //删除全部日程
      store.executeSql(query)
        .then(() => {
          console.info('Delete done.')
          emitter.emit({ eventId: 0 });   //发送事件，通知其他页面更新
        }).catch((err: BusinessError) => {
         console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }
    return
  }
}

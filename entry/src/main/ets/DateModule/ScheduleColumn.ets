import router from '@ohos.router'
import relationalStore from '@ohos.data.relationalStore'
import { theDate } from './theDate'
import { theTime } from './theTime'
import { Schedule } from './agendaStruct'
import { ScheduleBlock } from './ScheduleBlock'
import emitter from '@ohos.events.emitter'
import { GlobalContext } from '../GlobalContext/GlobalContext'

@Component
export struct ScheduleColumn {
  @Prop date: string //表示当前列展示的日期
  @State schedules: Schedule[] = [] //存储当天的所有日程信息，组件会根据这个数组渲染日程
  aboutToAppear() {
    emitter.on({eventId:0},()=>{
      this.loadSchedulesFromDb()
    })
    this.loadSchedulesFromDb() // 加载日程数据
  }

  // 从数据库加载日程数据
  loadSchedulesFromDb() {
    const store: relationalStore.RdbStore = GlobalContext.getInstance().getStore() as relationalStore.RdbStore;
    if (!store) {
      console.error('Store is not initialized.')
      return
    }
    const predicates = new relationalStore.RdbPredicates('SCHEDULES')
    predicates
      .equalTo('DATE', this.date)
      .greaterThanOrEqualTo('START', '00:00')
      .orderByAsc('START')
    store.query(predicates)
      .then((resultSet:relationalStore.ResultSet) => {
        this.schedules = [] // 清空现有的日程
        while (resultSet.goToNextRow()) {
          let schedule = new Schedule()
          schedule.ID = resultSet.getLong(resultSet.getColumnIndex('ID'))
          schedule.title = resultSet.getString(resultSet.getColumnIndex('TITLE'))
          schedule.description = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'))
          schedule.place = resultSet.getString(resultSet.getColumnIndex('PLACE'))
          schedule.date = resultSet.getString(resultSet.getColumnIndex('DATE'))
          schedule.start = resultSet.getString(resultSet.getColumnIndex('START'))
          schedule.end = resultSet.getString(resultSet.getColumnIndex('END'))
          schedule.color = resultSet.getString(resultSet.getColumnIndex('COLOR'))
          this.schedules.push(schedule)
        }
      })
  }

  build() {
    Column() {
      Stack() {
        ForEach(this.schedules, (item:Schedule, index:number)=>{
          ScheduleBlock({schedule:item})
        }, (item:Schedule)=>item.toString())
      }
    }
    .width('100%')
    .height(24 * 60)
  }

}
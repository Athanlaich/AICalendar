import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import relationalStore from '@ohos.data.relationalStore';
import { GlobalContext } from '../GlobalContext/GlobalContext'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    //数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'SchedulesRdb.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
    };
    // 建表Sql语句
    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS SCHEDULES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE STRING NOT NULL, DESCRIPTION STRING ,PLACE STRING , DATE STRING NOT NULL, START STRING NOT NULL, END STRING NOT NULL,COLOR STRING NOT NULL)';
    //获取数据库
    relationalStore.getRdbStore(this.context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get relational database. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Successful to get relational database.`);
      //建表
      store.executeSql(SQL_CREATE_TABLE, [], (err) => {
        if (err) {
          console.error(`Failed to create table. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`Successful to create table.`);
        GlobalContext.getInstance().setStore(store);
        //加载主页面
        windowStage.loadContent('pages/Index', (err, data) => {
          if (err.code) {
            hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
        });
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

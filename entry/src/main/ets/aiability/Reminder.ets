import notificationManager from '@ohos.notificationManager';
import relationalStore from '@ohos.data.relationalStore';
import { GlobalContext } from '../GlobalContext/GlobalContext';

export class Reminder {
  async checkReminders(date: string) {
    const currentTime = new Date().getTime();
    const store: relationalStore.RdbStore = GlobalContext.getInstance().getStore() as relationalStore.RdbStore;

    const predicates = new relationalStore.RdbPredicates('SCHEDULES');
    predicates.equalTo('DATE', date).greaterThanOrEqualTo('START', '00:00');

    const resultSet = await store.query(predicates);
    while (resultSet.goToNextRow()) {
      const scheduleStartTime = new Date(`${date} ${resultSet.getString(resultSet.getColumnIndex('START'))}`).getTime();
      const reminderTime = scheduleStartTime - 15 * 60 * 1000;

      if (currentTime >= reminderTime && currentTime < scheduleStartTime) {
        await this.publishNotification(resultSet);
      }
    }
  }

  async publishNotification(resultSet: relationalStore.ResultSet): Promise<void> {
    const title: string = resultSet.getString(resultSet.getColumnIndex('TITLE'));
    const description: string = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));

    await notificationManager.publish({
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: "日程提醒: " + title,
          text: "您的日程将在15分钟后开始: " + description,
        },
      },
      id: Date.now(),
    });
    console.log("Reminder published successfully.");
  }
}

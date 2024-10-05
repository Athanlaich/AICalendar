// theDate.ets是对日期的所有处理
export class theDate {
  // 定义一周的天数名称
  public static WEEKDAYS: string[] = [ '周日','周一', '周二', '周三', '周四', '周五', '周六'];

  // 获取今天的日期，格式为 'yyyy-MM-dd'
  public static today(): string {
    return theDate.date2yyyyMMDD(new Date());
  }
  //将 'yyyy-MM-dd' 字符串转化为Date类型
  private static parseDate(date: string): Date {
    return new Date(date);
  }

  // 返回指定日期所在周的七天，格式为 'yyyy-MM-dd',输入参数：date: string，返回一个字符串数组string[]
  public static daysInTheSameWeek(date: string): string[] {
    const ret: string[] = [];
    const baseDate: Date = theDate.parseDate(date); // 将字符串日期转为 Date 对象
    const dayOfWeek: number = baseDate.getDay(); // 获取该日期是星期几

    for (let i = 0; i < 7; i++) { // 遍历一周的七天
      //baseDate.getDay() 返回的是这个日期是星期几
      const currentDay: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() - dayOfWeek + i+1);
      ret.push(theDate.date2yyyyMMDD(currentDay)); // 转换为 'yyyy-MM-dd' 年月日格式并存储在字符数组的末尾
    }

    return ret; // 返回一周内所有日期,ret是一个包含该周所有日期的字符串数组，日期格式为yyyy-MM-dd，顺序从周一到周日
  }

  // 获取指定日期的年份
  public static getYear(date: string): number {
    return theDate.parseDate(date).getFullYear();
  }

  // 获取指定日期的月份（1 月 = 1，12 月 = 12），输入一个日期格式为yyyy-MM-dd的字符串，将字符串日期转为 Date 对象再获取月份
  public static getMonth(date: string): number {
    return theDate.parseDate(date).getMonth() + 1; // 月份是从 0 开始的，所以需要加 1
  }

  // 获取指定日期是该月的第几天
  public static getDate(date: string): number {
    return theDate.parseDate(date).getDate();
  }

  // 获取指定日期是周几（0 = 周日，1 = 周一，6 = 周六）
  public static getDay(date: string): number {
    return theDate.parseDate(date).getDay();
  }

  // 将 Date 对象转换为 'yyyy-MM-dd' 字符串
  public static date2yyyyMMDD(date: Date): string {
    const DD = String(date.getDate()).padStart(2, '0'); // 确保日是两位数
    //String(date.getDate()) 将数字转换为字符串。
    //.padStart(2, '0') 方法确保字符串至少是两位数，不足两位数时在前面填充 0。
    const MM = String(date.getMonth() + 1).padStart(2, '0'); // 确保月份是两位数
    const yyyy = String(date.getFullYear()); // 获取年份
    return `${yyyy}-${MM}-${DD}`; // 返回 'yyyy-MM-dd' 格式的字符串
  }

  // 根据偏移量调整日期，并返回新的日期（格式为 'yyyy-MM-dd'），快速计算某个日期的前七天或后七天
  public static dateWithOffset(date: string, offset: number): string {
    const baseDate: Date = theDate.parseDate(date); // 将字符串日期转换为 Date 对象
    // 根据偏移量调整日期
    const newDate = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
    return theDate.date2yyyyMMDD(newDate); // 返回调整后的日期，格式为 'yyyy-MM-dd'
  }

  // 获取指定日期对应的星期几的名称
  public static getWeekday(date: string): string {
    const dayIndex: number = theDate.getDay(date);
    return theDate.WEEKDAYS[dayIndex];
  }
  //是否是今天
  public static isToday(date: string): boolean {
    const today = new Date();
    const inputDate = theDate.parseDate(date);
    return (
      inputDate.getFullYear() === today.getFullYear() &&
        inputDate.getMonth() === today.getMonth() &&
        inputDate.getDate() === today.getDate()
    );
  }
}
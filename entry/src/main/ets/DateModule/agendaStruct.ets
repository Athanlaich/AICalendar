import { theDate } from './theDate';
import { theTime } from './theTime';

// 封装日程数据的数据结构
export class Schedule {
  public ID: number = -1; // 唯一标识符，初始值为 -1
  public title: string = ""; // 日程标题，初始为空字符串
  public description: string = ""; // 日程描述，初始为空字符串
  public place: string = ""; // 日程地点，初始为空字符串
  public date: string = theDate.today(); // 日程日期，初始为当前日期
  public start: string = theTime.now(); // 日程开始时间，初始为当前时间（hh:mm格式）
  public end: string = theTime.now(); // 日程结束时间，初始为当前时间（hh:mm格式）
  public static COLORS: string[] = ['#ffbc4442', '#ff5c8c65', '#ffdbcf8f', '#ff2a6ad2', 'b39fab']; // 定义颜色数组
  public color: string = Schedule.COLORS[0]; // 默认颜色为 COLORS 数组的第一个颜色

  // 将日程对象转换为以逗号分隔的字符串
  public toString(): string {
    return `${this.ID},${this.title},${this.description},${this.place},${this.date},${this.start},${this.end}`//这些应该会存入数据库
  }
}
//import { theDate } from './theDate';  // 导入日期相关的封装库

export class theTime {
  // 定义一天中的小时
  public static HOURS: string[] = [
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11',
    '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23','24'
  ];

  // 将 Date 对象转换为 'hh:mm' 格式的时间字符串
  public static date2hhmm(date: Date): string {
    const hh: string = String(date.getHours()).padStart(2, '0');  // 获取小时，确保两位数
    const mm: string = String(date.getMinutes()).padStart(2, '0');  // 获取分钟，确保两位数
    return `${hh}:${mm}`;  // 返回 'hh:mm' 格式的字符串
  }

  // 获取当前时间，返回 'hh:mm' 格式的时间字符串
  public static now(): string {
    return theTime.date2hhmm(new Date());  // 返回当前时间
  }

  // 从时间字符串（'hh:mm' 格式）中提取小时部分
  public static getHours(time: string): number {
    return Number(time.split(':')[0]);  // 解析小时部分
  }

  // 从时间字符串（'hh:mm' 格式）中提取分钟部分
  public static getMinutes(time: string): number {
    return Number(time.split(':')[1]);  // 解析分钟部分
  }

  // 计算两个时间之间的时间间隔（以分钟为单位）
  public static getDuration(start: string, end: string): number {
    return 60 * (theTime.getHours(end) - theTime.getHours(start)) + theTime.getMinutes(end) - theTime.getMinutes(start);
  }

  //根据时间获得位置
  public static hhmm2position(time: string): number {
    const hours = theTime.getHours(time);
    const minutes = theTime.getMinutes(time);
    const position = hours * 60 + minutes;
    console.log(`时间: ${time}, 位置(分钟): ${position}`); // 输出时间和对应的位置
    return position;
  }


  // 时间加上偏移量（以分钟为单位），确保结果在当天范围内
  public static timeWithOffset(time: string, offset: number): string {
    // 从时间字符串中提取小时部分
    const hours: number = theTime.getHours(time);
    // 从时间字符串中提取分钟部分
    const minutes: number = theTime.getMinutes(time);
    // 将小时和分钟转换为总分钟数，并加上偏移量
    let totalMinutes: number = hours * 60 + minutes + offset;
    // 确保总分钟数不小于 0，防止负值
    totalMinutes = Math.max(totalMinutes, 0);
    // 确保总分钟数不超过 23:59，防止超出一天的最大分钟数
    totalMinutes = Math.min(totalMinutes, 23 * 60 + 59);
    // 将总分钟数转换回小时和分钟，并返回 'hh:mm' 格式的时间字符串
    return `${Math.floor(totalMinutes / 60).toString().padStart(2, '0')}:${Math.floor(totalMinutes % 60).toString().padStart(2, '0')}`;
  }

}
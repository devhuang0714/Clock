import I18n from '@ohos.i18n';

// 天干地支
const tiangan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"];
const dizhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"];

// 定义数字到农历日表示的映射
const chineseNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"];
const chineseDays = ["初", "十", "廿", "三"];

// 日历，用来获取农历日期
export const chinesCalendar: I18n.Calendar = I18n.getCalendar("zh-Hans", "chinese");

export class DateUtils {
  /**
   * 格式化阳历年月日
   * @param date
   * @returns 阳历日期
   */
  static formatDate = (date: Date, format = 'yyyy-MM-dd HH:mm:ss'): string => {
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const hour = date.getHours()
    const minute = date.getMinutes()
    const second = date.getSeconds()
    const formatMap: Record<string, string> = {
      'yyyy': year.toString(),
      'MM': month.toString(),
      'dd': day.toString(),
      'HH': hour.toString(),
      'mm': minute.toString(),
      'ss': second.toString()
    }
    return format.replace(new RegExp('yyyy|MM|dd|HH|mm|ss', 'g'), (match: string) => {
      return formatMap[match].padStart(2, '0')
    })
  }
  /**
   * 格式化农历年月日
   * @param date
   * @returns 农历日期
   */
  static formatLunarDate = (date: Date, format = 'yyyy年MM月dd日'): string => {
    const year = DateUtils.getLunarYear(date)
    const month = DateUtils.getLunarMonth(date)
    const day = DateUtils.getLunarDay(date)
    const formatMap: Record<string, string> = {
      'yyyy': year.toString(),
      'MM': month.toString(),
      'dd': day.toString()
    }
    return format.replace(new RegExp('yyyy|MM|dd|HH|mm|ss', 'g'), (match: string) => {
      return formatMap[match]
    })
  }

  static getWeek_EN(weekDay: number): string {
    switch (weekDay) {
      case 1:
        return 'MONDAY'
      case 2:
        return 'TUESDAY'
      case 3:
        return 'WEDNESDAY'
      case 4:
        return 'THURSDAY'
      case 5:
        return 'FRIDAY'
      case 6:
        return 'SATURDAY'
      case 7:
        return 'SUNDAY'
    }
    return ''
  }

  static getWeek_ZH(weekDay: number): string {
    switch (weekDay) {
      case 1:
        return '星期一'
      case 2:
        return '星期二'
      case 3:
        return '星期三'
      case 4:
        return '星期四'
      case 5:
        return '星期五'
      case 6:
        return '星期六'
      case 7:
        return '星期日'
    }
    return ''
  }

  /**
   * 根据干支纪年返回农历年
   * @param year - 公历年
   * @returns 农历干支纪年
   */
  static getLunarYear(date: Date): string {
    //将公历信息设置到calendar对象
    chinesCalendar.setTime(date);
    //获取农历年月日
    const lunarYear = chinesCalendar.get("year"); // 返回干支纪年40，范围1-60

    // 计算天干和地支的位置
    const tianganIndex = (lunarYear - 1) % 10;
    const dizhiIndex = (lunarYear - 1) % 12;
    return `${tiangan[tianganIndex]}${dizhi[dizhiIndex]}`;
  }

  /**
   * 将数字转换为农历月写法
   * @param date
   * @returns 农历日的中文写法
   */
  static getLunarMonth(date: Date): string {
    chinesCalendar.setTime(date);
    const chineseMonth = chinesCalendar.get("month") // 结果为5，指6月
    return chineseNumbers[chineseMonth % 12]
  }

  /**
   * 将数字转换为农历日写法
   * @param date
   * @returns 农历日的中文写法
   */
  static getLunarDay(date: Date): string {
    chinesCalendar.setTime(date);
    const chineseDay = chinesCalendar.get("date");

    if (chineseDay <= 10) {
      return `初${chineseNumbers[chineseDay - 1]}`;
    } else if (chineseDay <= 19) {
      return `十${chineseNumbers[(chineseDay % 10) - 1]}`;
    } else if (chineseDay === 20) {
      return "二十";
    } else if (chineseDay <= 29) {
      return `廿${chineseNumbers[(chineseDay % 10) - 1]}`;
    } else if (chineseDay === 30) {
      return "三十";
    }

    return "";
  }

  /**
   * 获取12小时制 时
   * @param date
   * @returns 12小时制 时
   */
  static get12Hour(date: Date): number {
    return date.getHours() % 12 === 0 ? 12 : date.getHours() % 12
  }

  /**
   * 获取 AM PM
   * @param hours
   * @returns AM ｜ PM
   */
  static getPeriod(hours: number): string {
    return hours >= 12 ? 'PM' : 'AM'
  }
}
// 天干和地支列表
const tiangan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"];
const dizhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"];

// 基准年及其干支（如1984年是甲子年）
const baseYear = 1984;
const baseTiangan = 0; // "甲"
const baseDizhi = 0; // "子"

// 定义数字到农历日表示的映射
const chineseNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"];
const chineseDays = ["初", "十", "廿", "三"];

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
    const year = DateUtils.getLunarYear(date.getFullYear())
    const month = DateUtils.getLunarMonth(date.getMonth() + 1)
    const day = DateUtils.getLunarDay(date.getDate())
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
  static getLunarYear(year: number): string {
    // 计算与基准年的差距
    const offset = year - baseYear;

    // 计算天干和地支的位置
    const tianganIndex = (baseTiangan + offset) % 10;
    const dizhiIndex = (baseDizhi + offset) % 12;

    // 处理负数情况
    const tianganFinalIndex = (tianganIndex + 10) % 10;
    const dizhiFinalIndex = (dizhiIndex + 12) % 12;

    return `${tiangan[tianganFinalIndex]}${dizhi[dizhiFinalIndex]}`;
  }

  /**
   * 将数字转换为农历月写法
   * @param day - 农历月（1到12）
   * @returns 农历日的中文写法
   */
  static getLunarMonth(month: number): string {
    return chineseNumbers[(month - 1) % 12]
  }

  /**
   * 将数字转换为农历日写法
   * @param day - 农历日（1到30）
   * @returns 农历日的中文写法
   */
  static getLunarDay(day: number): string {
    if (day < 1 || day > 30) {
      throw new Error("农历日应在1到30之间");
    }

    if (day <= 10) {
      return `初${chineseNumbers[day - 1]}`;
    } else if (day <= 20) {
      return `十${day === 20 ? "" : chineseNumbers[day - 11]}`;
    } else if (day <= 30) {
      return `${chineseDays[Math.floor(day / 10)]}${chineseNumbers[(day % 10) - 1]}`;
    }

    return "";
  }
}
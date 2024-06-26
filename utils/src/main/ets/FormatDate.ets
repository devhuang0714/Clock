export const formatDate = (date: Date, format = 'yyyy-MM-dd HH:mm:ss'): string => {
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
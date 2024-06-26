export const formatCurrency = (amount: number): string => {
  const yuan = amount / 100
  return yuan.toLocaleString('zh-CN', {
    style: 'currency',
    currency: 'CNY'
  })
}
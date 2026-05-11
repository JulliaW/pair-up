/**
 * Utilitários de formatação para o PairUp
 */

/**
 * Formata valor numérico para moeda brasileira (BRL)
 * @param {number} value
 * @returns {string} Ex: "R$ 1.234,56"
 */
export function formatCurrency(value) {
  if (value === null || value === undefined || isNaN(value)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(value)
}

/**
 * Formata data para formato brasileiro
 * @param {string|Date} date
 * @param {boolean} includeTime - Se deve incluir horário
 * @returns {string} Ex: "15/05/2026" ou "15/05/2026 14:30"
 */
export function formatDate(date, includeTime = false) {
  if (!date) return ''
  const d = new Date(date)
  if (isNaN(d.getTime())) return ''

  const options = {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  }

  if (includeTime) {
    options.hour = '2-digit'
    options.minute = '2-digit'
  }

  return d.toLocaleDateString('pt-BR', options)
}

/**
 * Retorna o nome do mês em português
 * @param {number} month - 0-11
 * @param {boolean} abbreviated - Se deve retornar abreviado
 * @returns {string}
 */
export function getMonthName(month, abbreviated = false) {
  const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ]
  const abbr = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ]
  return abbreviated ? abbr[month] : months[month]
}

/**
 * Formata uma data para exibição relativa (ex: "Há 2 horas", "Ontem")
 * @param {string|Date} date
 * @returns {string}
 */
export function formatRelativeTime(date) {
  if (!date) return ''
  const now = new Date()
  const d = new Date(date)
  const diffMs = now - d
  const diffMinutes = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMinutes / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffMinutes < 1) return 'Agora mesmo'
  if (diffMinutes < 60) return `Há ${diffMinutes} min`
  if (diffHours < 24) return `Há ${diffHours}h`
  if (diffDays === 1) return 'Ontem'
  if (diffDays < 7) return `Há ${diffDays} dias`
  return formatDate(date)
}

/**
 * Retorna o status financeiro formatado
 * @param {string} status
 * @returns {{ label: string, color: string, icon: string }}
 */
export function getTransactionStatus(status) {
  const statusMap = {
    pending: { label: 'Pendente', color: 'warning', icon: 'pending' },
    paid: { label: 'Pago', color: 'positive', icon: 'check_circle' },
    overdue: { label: 'Vencido', color: 'negative', icon: 'error' },
    cancelled: { label: 'Cancelado', color: 'grey', icon: 'cancel' }
  }
  return statusMap[status] || { label: status, color: 'grey', icon: 'help' }
}

/**
 * Retorna label e cor para prioridade de tarefa
 * @param {string} priority
 * @returns {{ label: string, color: string }}
 */
export function getPriorityInfo(priority) {
  const priorityMap = {
    low: { label: 'Baixa', color: 'positive' },
    medium: { label: 'Média', color: 'warning' },
    high: { label: 'Alta', color: 'negative' }
  }
  return priorityMap[priority] || { label: priority, color: 'grey' }
}

/**
 * Retorna label e cor para status de tarefa
 * @param {string} status
 * @returns {{ label: string, color: string }}
 */
export function getTaskStatusInfo(status) {
  const statusMap = {
    todo: { label: 'A fazer', color: 'grey' },
    in_progress: { label: 'Em andamento', color: 'info' },
    done: { label: 'Concluída', color: 'positive' }
  }
  return statusMap[status] || { label: status, color: 'grey' }
}

/**
 * Gera as cores para categorias de gastos (para gráficos)
 */
export const CATEGORY_COLORS = [
  '#5C6BC0', '#26A69A', '#FF7043', '#42A5F5', '#AB47BC',
  '#66BB6A', '#FFA726', '#EF5350', '#78909C', '#8D6E63',
  '#29B6F6', '#EC407A', '#9CCC65', '#7CB342', '#F06292'
]

/**
 * Trunca texto com ellipsis
 * @param {string} text
 * @param {number} maxLength
 * @returns {string}
 */
export function truncateText(text, maxLength = 50) {
  if (!text || text.length <= maxLength) return text || ''
  return text.substring(0, maxLength) + '...'
}
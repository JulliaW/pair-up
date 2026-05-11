import { supabase } from './supabaseClient'

/**
 * Funções auxiliares centralizadas para consultas ao Supabase.
 * Todas as consultas são filtradas por couple_id para respeitar o RLS.
 */

// ========================
// EVENTOS (Agenda)
// ========================

export async function fetchEvents(coupleId, startDate, endDate) {
  const { data, error } = await supabase
    .from('agenda_events')
    .select('*')
    .eq('couple_id', coupleId)
    .gte('event_date', startDate)
    .lte('event_date', endDate)
    .order('event_date', { ascending: true })
    .order('event_time', { ascending: true })

  return { data, error }
}

export async function createEvent(event) {
  const { data, error } = await supabase
    .from('agenda_events')
    .insert(event)
    .select()
    .single()

  return { data, error }
}

export async function updateEvent(id, updates) {
  const { data, error } = await supabase
    .from('agenda_events')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}

export async function deleteEvent(id) {
  const { error } = await supabase
    .from('agenda_events')
    .delete()
    .eq('id', id)

  return { error }
}

// ========================
// LISTA DE COMPRAS
// ========================

export async function fetchShoppingMonth(coupleId, month, year) {
  const { data: monthData, error: monthError } = await supabase
    .from('shopping_months')
    .select('*')
    .eq('couple_id', coupleId)
    .eq('month', month)
    .eq('year', year)
    .maybeSingle()

  if (monthError) return { data: null, error: monthError }

  if (!monthData) {
    return { data: null, error: null }
  }

  const { data: items, error: itemsError } = await supabase
    .from('shopping_items')
    .select('*')
    .eq('shopping_month_id', monthData.id)
    .order('category', { ascending: true })

  return { data: { ...monthData, items: items || [] }, error: itemsError }
}

export async function createShoppingMonth(coupleId, month, year) {
  const { data, error } = await supabase
    .from('shopping_months')
    .insert({ couple_id: coupleId, month, year })
    .select()
    .single()

  return { data, error }
}

export async function addShoppingItem(item) {
  const { data, error } = await supabase
    .from('shopping_items')
    .insert(item)
    .select()
    .single()

  return { data, error }
}

export async function updateShoppingItem(id, updates) {
  const { data, error } = await supabase
    .from('shopping_items')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}

export async function rolloverItems(coupleId, fromMonthId, toMonthId) {
  // Busca itens não comprados do mês anterior
  const { data: pendingItems, error: fetchError } = await supabase
    .from('shopping_items')
    .select('*')
    .eq('shopping_month_id', fromMonthId)
    .neq('status', 'purchased')

  if (fetchError) return { error: fetchError }

  if (!pendingItems || pendingItems.length === 0) {
    return { data: [], error: null }
  }

  // Marca como "rolled_over"
  const { error: updateError } = await supabase
    .from('shopping_items')
    .update({ status: 'rolled_over' })
    .eq('shopping_month_id', fromMonthId)
    .neq('status', 'purchased')

  if (updateError) return { error: updateError }

  // Cria novos itens para o mês atual
  const newItems = pendingItems.map(item => ({
    shopping_month_id: toMonthId,
    name: item.name,
    quantity: item.quantity,
    category: item.category,
    notes: item.notes,
    status: 'pending'
  }))

  const { data, error } = await supabase
    .from('shopping_items')
    .insert(newItems)
    .select()

  return { data, error }
}

// ========================
// TAREFAS
// ========================

export async function fetchTasks(coupleId, filters = {}) {
  let query = supabase
    .from('tasks')
    .select('*')
    .eq('couple_id', coupleId)

  if (filters.status) {
    query = query.eq('status', filters.status)
  }
  if (filters.priority) {
    query = query.eq('priority', filters.priority)
  }
  if (filters.responsibleUserId) {
    query = query.eq('responsible_user_id', filters.responsibleUserId)
  }

  query = query.order('created_at', { ascending: false })

  const { data, error } = await query
  return { data, error }
}

export async function createTask(task) {
  const { data, error } = await supabase
    .from('tasks')
    .insert(task)
    .select()
    .single()

  return { data, error }
}

export async function updateTask(id, updates) {
  const { data, error } = await supabase
    .from('tasks')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}

export async function deleteTask(id) {
  const { error } = await supabase
    .from('tasks')
    .delete()
    .eq('id', id)

  return { error }
}

// ========================
// METAS
// ========================

export async function fetchGoals(coupleId) {
  const { data, error } = await supabase
    .from('goals')
    .select('*, goal_milestones(*)')
    .eq('couple_id', coupleId)
    .order('created_at', { ascending: false })

  return { data, error }
}

export async function createGoal(goal) {
  const { data, error } = await supabase
    .from('goals')
    .insert(goal)
    .select()
    .single()

  return { data, error }
}

export async function updateGoal(id, updates) {
  const { data, error } = await supabase
    .from('goals')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}

// ========================
// TRANSAÇÕES
// ========================

export async function fetchTransactions(coupleId, month, year) {
  const startDate = `${year}-${String(month).padStart(2, '0')}-01`
  const endDate = new Date(year, month, 0).toISOString().split('T')[0]

  const { data, error } = await supabase
    .from('transactions')
    .select('*, categories(*)')
    .eq('couple_id', coupleId)
    .gte('date', startDate)
    .lte('date', endDate)
    .order('date', { ascending: false })

  return { data, error }
}

export async function createTransaction(transaction) {
  const { data, error } = await supabase
    .from('transactions')
    .insert(transaction)
    .select()
    .single()

  return { data, error }
}

// ========================
// CATEGORIAS
// ========================

export async function fetchCategories(coupleId) {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .or(`couple_id.eq.${coupleId},is_default.eq.true`)
    .order('name', { ascending: true })

  return { data, error }
}

// ========================
// CARTÕES DE CRÉDITO
// ========================

export async function fetchCreditCards(coupleId) {
  const { data, error } = await supabase
    .from('credit_cards')
    .select('*')
    .eq('couple_id', coupleId)
    .order('name', { ascending: true })

  return { data, error }
}

export async function createCreditCard(card) {
  const { data, error } = await supabase
    .from('credit_cards')
    .insert(card)
    .select()
    .single()

  return { data, error }
}

// ========================
// PARCELAS
// ========================

export async function generateInstallments(transaction) {
  // Registro mestre do parcelamento
  const { data, error } = await supabase
    .from('installments')
    .insert({
      couple_id: transaction.couple_id,
      card_id: transaction.card_id,
      total_amount: transaction.amount,
      total_installments: transaction.total_installments,
      current_installment: 1
    })
    .select()
    .single()

  return { data, error }
}

// ========================
// APARTAMENTO / PROPRIEDADE
// ========================

export async function fetchProperty(coupleId) {
  const { data, error } = await supabase
    .from('properties')
    .select('*')
    .eq('couple_id', coupleId)
    .maybeSingle()

  return { data, error }
}

export async function createProperty(property) {
  const { data, error } = await supabase
    .from('properties')
    .insert(property)
    .select()
    .single()

  return { data, error }
}

export async function updateProperty(id, updates) {
  const { data, error } = await supabase
    .from('properties')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}

export async function addPropertyEvolution(evolution) {
  const { data, error } = await supabase
    .from('property_evolution')
    .insert(evolution)
    .select()
    .single()

  return { data, error }
}

export async function fetchPropertyEvolution(propertyId) {
  const { data, error } = await supabase
    .from('property_evolution')
    .select('*')
    .eq('property_id', propertyId)
    .order('year', { ascending: true })
    .order('month', { ascending: true })

  return { data, error }
}

// ========================
// COFRINHO (Savings Goals)
// ========================

export async function fetchSavingsGoals(coupleId) {
  const { data, error } = await supabase
    .from('savings_goals')
    .select('*')
    .eq('couple_id', coupleId)
    .order('created_at', { ascending: false })

  return { data, error }
}

export async function createSavingsGoal(goal) {
  const { data, error } = await supabase
    .from('savings_goals')
    .insert(goal)
    .select()
    .single()

  return { data, error }
}

export async function updateSavingsGoal(id, updates) {
  const { data, error } = await supabase
    .from('savings_goals')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  return { data, error }
}
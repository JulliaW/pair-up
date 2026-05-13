import { defineStore } from 'pinia'
import { supabase } from 'src/services/supabaseClient'
import { useAuthStore } from './authStore'

export const useFinanceStore = defineStore('finance', {
  state: () => ({
    transactions: [],
    categories: [],
    creditCards: [],
    property: null,
    propertyTransactions: [],
    propertyEvolution: [],
    savingsGoals: [],
    currentMonth: new Date().getMonth() + 1,
    currentYear: new Date().getFullYear(),
    loading: false
  }),

  getters: {
    monthIncome: (state) => {
      return state.transactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + Number(t.amount), 0)
    },
    monthExpenses: (state) => {
      return state.transactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + Number(t.amount), 0)
    },
    monthBalance: (state) => {
      const income = state.transactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + Number(t.amount), 0)
      const expenses = state.transactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + Number(t.amount), 0)
      return income - expenses
    },
    transactionsByCategory: (state) => {
      const grouped = {}
      state.transactions.forEach(t => {
        const catName = t.categories?.name || 'Sem categoria'
        if (!grouped[catName]) {
          grouped[catName] = { name: catName, total: 0, color: t.categories?.color || '#999', count: 0 }
        }
        grouped[catName].total += Number(t.amount)
        grouped[catName].count++
      })
      return Object.values(grouped).sort((a, b) => b.total - a.total)
    },
    expensesByCategory: (state) => {
      const grouped = {}
      state.transactions
        .filter(t => t.type === 'expense')
        .forEach(t => {
          const catName = t.categories?.name || 'Sem categoria'
          if (!grouped[catName]) {
            grouped[catName] = { name: catName, total: 0, color: t.categories?.color || '#999', count: 0 }
          }
          grouped[catName].total += Number(t.amount)
          grouped[catName].count++
        })
      return Object.values(grouped).sort((a, b) => b.total - a.total)
    },
    propertyExpensesByCategory: (state) => {
      const grouped = {}
      ;(state.propertyTransactions || []).forEach(t => {
        const catName = t.categories?.name || 'Sem categoria'
        if (!grouped[catName]) {
          grouped[catName] = { name: catName, total: 0, color: t.categories?.color || '#999', count: 0 }
        }
        grouped[catName].total += Number(t.amount)
        grouped[catName].count++
      })
      return Object.values(grouped).sort((a, b) => b.total - a.total)
    },
    propertyMonthTotal: (state) => {
      return (state.propertyTransactions || [])
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + Number(t.amount), 0)
    }
  },

  actions: {
    async fetchTransactions () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      this.loading = true
      try {
        const startDate = `${this.currentYear}-${String(this.currentMonth).padStart(2, '0')}-01`
        const endDate = new Date(this.currentYear, this.currentMonth, 0)
          .toISOString().split('T')[0]

        const { data, error } = await supabase
          .from('transactions')
          .select('id, type, amount, description, date, category_id, card_id, is_recurring, created_by, created_at, categories(id, name, type, icon, color, scope)')
          .eq('couple_id', authStore.coupleId)
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date', { ascending: false })

        if (error) throw error
        this.transactions = data || []
      } catch (err) {
        console.error('Erro ao buscar transações:', err)
      } finally {
        this.loading = false
      }
    },

    async fetchPropertyTransactions () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      try {
        const startDate = `${this.currentYear}-${String(this.currentMonth).padStart(2, '0')}-01`
        const endDate = new Date(this.currentYear, this.currentMonth, 0)
          .toISOString().split('T')[0]

        const { data, error } = await supabase
          .from('transactions')
          .select('id, type, amount, description, date, category_id, card_id, is_recurring, created_by, created_at, categories(id, name, type, icon, color, scope)')
          .eq('couple_id', authStore.coupleId)
          .eq('property_related', true)
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date', { ascending: false })

        if (error) throw error
        this.propertyTransactions = data || []
      } catch (err) {
        console.error('Erro ao buscar transações do apartamento:', err)
      }
    },

    async createTransaction (transaction) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal vinculado' }

      this.loading = true
      try {
        const { data, error } = await supabase
          .from('transactions')
          .insert({
            couple_id: authStore.coupleId,
            type: transaction.type,
            amount: transaction.amount,
            description: transaction.description,
            date: transaction.date,
            category_id: transaction.category_id || null,
            card_id: transaction.card_id || null,
            property_related: transaction.property_related || false,
            property_id: transaction.property_id || null,
            is_recurring: transaction.is_recurring || false,
            created_by: authStore.user?.id
          })
          .select('id, type, amount, description, date, category_id, card_id, is_recurring, created_by, created_at, categories(id, name, type, icon, color, scope)')
          .single()

        if (error) throw error
        this.transactions.unshift(data)
        if (transaction.property_related) {
          this.propertyTransactions.unshift(data)
        }
        return { success: true, data }
      } catch (err) {
        console.error('Erro ao criar transação:', err)
        return { success: false, error: err.message }
      } finally {
        this.loading = false
      }
    },

    async deleteTransaction (id) {
      try {
        const { error } = await supabase
          .from('transactions')
          .delete()
          .eq('id', id)

        if (error) throw error
        this.transactions = this.transactions.filter(t => t.id !== id)
        this.propertyTransactions = this.propertyTransactions.filter(t => t.id !== id)
        return { success: true }
      } catch (err) {
        console.error('Erro ao deletar transação:', err)
        return { success: false, error: err.message }
      }
    },

    async fetchCategories () {
      const authStore = useAuthStore()
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .or(`couple_id.eq.${authStore.coupleId},is_default.eq.true`)
        .order('name')

      if (!error) this.categories = data || []
    },

    async fetchCreditCards () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      const { data, error } = await supabase
        .from('credit_cards')
        .select('*')
        .eq('couple_id', authStore.coupleId)
        .order('name')

      if (!error) this.creditCards = data || []
    },

    async createCreditCard (card) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal' }

      try {
        const { data, error } = await supabase
          .from('credit_cards')
          .insert({ ...card, couple_id: authStore.coupleId })
          .select()
          .single()

        if (error) throw error
        this.creditCards.push(data)
        return { success: true, data }
      } catch (err) {
        return { success: false, error: err.message }
      }
    },

    async fetchProperty () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      const { data, error } = await supabase
        .from('properties')
        .select('*')
        .eq('couple_id', authStore.coupleId)
        .maybeSingle()

      if (!error) this.property = data
    },

    async createOrUpdateProperty (property) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal' }

      try {
        if (this.property) {
          const { data, error } = await supabase
            .from('properties')
            .update(property)
            .eq('id', this.property.id)
            .select()
            .single()
          if (error) throw error
          this.property = data
        } else {
          const { data, error } = await supabase
            .from('properties')
            .insert({ ...property, couple_id: authStore.coupleId })
            .select()
            .single()
          if (error) throw error
          this.property = data
        }
        return { success: true }
      } catch (err) {
        return { success: false, error: err.message }
      }
    },

    async fetchSavingsGoals () {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return

      const { data, error } = await supabase
        .from('savings_goals')
        .select('*')
        .eq('couple_id', authStore.coupleId)
        .order('created_at', { ascending: false })

      if (!error) this.savingsGoals = data || []
    },

    async createSavingsGoal (goal) {
      const authStore = useAuthStore()
      if (!authStore.coupleId) return { success: false, error: 'Sem casal' }

      try {
        const { data, error } = await supabase
          .from('savings_goals')
          .insert({ ...goal, couple_id: authStore.coupleId })
          .select()
          .single()

        if (error) throw error
        this.savingsGoals.push(data)
        return { success: true, data }
      } catch (err) {
        return { success: false, error: err.message }
      }
    },

    async updateSavingsGoal (id, updates) {
      try {
        const { data, error } = await supabase
          .from('savings_goals')
          .update(updates)
          .eq('id', id)
          .select()
          .single()

        if (error) throw error
        const idx = this.savingsGoals.findIndex(g => g.id === id)
        if (idx !== -1) this.savingsGoals[idx] = data
        return { success: true }
      } catch (err) {
        return { success: false, error: err.message }
      }
    },

    changeMonth (month, year) {
      this.currentMonth = month
      this.currentYear = year
      this.fetchTransactions()
      this.fetchPropertyTransactions()
    },

    nextMonth () {
      if (this.currentMonth === 12) {
        this.currentMonth = 1
        this.currentYear++
      } else {
        this.currentMonth++
      }
      this.fetchTransactions()
      this.fetchPropertyTransactions()
    },

    prevMonth () {
      if (this.currentMonth === 1) {
        this.currentMonth = 12
        this.currentYear--
      } else {
        this.currentMonth--
      }
      this.fetchTransactions()
      this.fetchPropertyTransactions()
    }
  }
})
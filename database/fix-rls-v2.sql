-- =============================================
-- Correção RLS v2: Resolver ambiguidade de couple_id
-- =============================================
-- CORREÇÃO: Todas as referências a couple_id nas policies agora
-- usam o prefixo da tabela (ex: transactions.couple_id) para
-- evitar ambiguidade com a coluna couple_id na função get_user_couple_id()
--
-- TAMBÉM: Remove as policies antigas do seed.sql que usam
-- nomes genéricos (couple_data_select, etc.) e que não estavam
-- sendo removidas anteriormente

-- =============================================
-- PASSO 1: Remover TODAS as policies antigas (nomes do seed.sql)
-- que podem estar causando ambiguidade
-- =============================================

-- Limpeza das policies antigas com nomes genéricos (seed.sql)
DROP POLICY IF EXISTS "couple_data_select" ON agenda_events;
DROP POLICY IF EXISTS "couple_data_insert" ON agenda_events;
DROP POLICY IF EXISTS "couple_data_update" ON agenda_events;
DROP POLICY IF EXISTS "couple_data_delete" ON agenda_events;

DROP POLICY IF EXISTS "couple_data_select" ON transactions;
DROP POLICY IF EXISTS "couple_data_insert" ON transactions;
DROP POLICY IF EXISTS "couple_data_update" ON transactions;
DROP POLICY IF EXISTS "couple_data_delete" ON transactions;

DROP POLICY IF EXISTS "couple_data_select" ON categories;
DROP POLICY IF EXISTS "couple_data_insert" ON categories;
DROP POLICY IF EXISTS "couple_data_update" ON categories;
DROP POLICY IF EXISTS "couple_data_delete" ON categories;

DROP POLICY IF EXISTS "couple_data_select" ON credit_cards;
DROP POLICY IF EXISTS "couple_data_insert" ON credit_cards;
DROP POLICY IF EXISTS "couple_data_update" ON credit_cards;
DROP POLICY IF EXISTS "couple_data_delete" ON credit_cards;

DROP POLICY IF EXISTS "couple_data_select" ON properties;
DROP POLICY IF EXISTS "couple_data_insert" ON properties;
DROP POLICY IF EXISTS "couple_data_update" ON properties;
DROP POLICY IF EXISTS "couple_data_delete" ON properties;

DROP POLICY IF EXISTS "couple_data_select" ON savings_goals;
DROP POLICY IF EXISTS "couple_data_insert" ON savings_goals;
DROP POLICY IF EXISTS "couple_data_update" ON savings_goals;
DROP POLICY IF EXISTS "couple_data_delete" ON savings_goals;

DROP POLICY IF EXISTS "couple_data_select" ON shopping_months;
DROP POLICY IF EXISTS "couple_data_insert" ON shopping_months;
DROP POLICY IF EXISTS "couple_data_update" ON shopping_months;
DROP POLICY IF EXISTS "couple_data_delete" ON shopping_months;

DROP POLICY IF EXISTS "couple_data_select" ON tasks;
DROP POLICY IF EXISTS "couple_data_insert" ON tasks;
DROP POLICY IF EXISTS "couple_data_update" ON tasks;
DROP POLICY IF EXISTS "couple_data_delete" ON tasks;

DROP POLICY IF EXISTS "couple_data_select" ON goals;
DROP POLICY IF EXISTS "couple_data_insert" ON goals;
DROP POLICY IF EXISTS "couple_data_update" ON goals;
DROP POLICY IF EXISTS "couple_data_delete" ON goals;

DROP POLICY IF EXISTS "couple_data_select" ON installments;
DROP POLICY IF EXISTS "couple_data_insert" ON installments;
DROP POLICY IF EXISTS "couple_data_update" ON installments;
DROP POLICY IF EXISTS "couple_data_delete" ON installments;

-- Também remove policies antigas com nomes do seed.sql para outras tabelas
DROP POLICY IF EXISTS "couple_data_select" ON property_evolution;
DROP POLICY IF EXISTS "couple_data_insert" ON property_evolution;
DROP POLICY IF EXISTS "couple_data_update" ON property_evolution;
DROP POLICY IF EXISTS "couple_data_delete" ON property_evolution;

DROP POLICY IF EXISTS "couple_data_select" ON shopping_items;
DROP POLICY IF EXISTS "couple_data_insert" ON shopping_items;
DROP POLICY IF EXISTS "couple_data_update" ON shopping_items;
DROP POLICY IF EXISTS "couple_data_delete" ON shopping_items;

DROP POLICY IF EXISTS "couple_data_select" ON goal_milestones;
DROP POLICY IF EXISTS "couple_data_insert" ON goal_milestones;
DROP POLICY IF EXISTS "couple_data_update" ON goal_milestones;
DROP POLICY IF EXISTS "couple_data_delete" ON goal_milestones;

-- Também remove as policies com nomes específicos do seed.sql para
-- shopping_items, goal_milestones e property_evolution
DROP POLICY IF EXISTS "shopping_items_select" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_insert" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_update" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_delete" ON shopping_items;

DROP POLICY IF EXISTS "goal_milestones_select" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_insert" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_update" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_delete" ON goal_milestones;

DROP POLICY IF EXISTS "property_evolution_select" ON property_evolution;
DROP POLICY IF EXISTS "property_evolution_insert" ON property_evolution;
DROP POLICY IF EXISTS "property_evolution_update" ON property_evolution;
DROP POLICY IF EXISTS "property_evolution_delete" ON property_evolution;

-- =============================================
-- PASSO 2: Recriar a função is_couple_member do seed.sql
-- com parâmetro qualificado para evitar ambiguidade
-- =============================================

-- Necessário DROP primeiro porque estamos mudando o nome do parâmetro
DROP FUNCTION IF EXISTS public.is_couple_member(UUID);
CREATE OR REPLACE FUNCTION public.is_couple_member(p_couple_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid() AND users.couple_id = p_couple_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- PASSO 3: Criar função auxiliar para obter couple_id do usuário
-- =============================================
CREATE OR REPLACE FUNCTION get_user_couple_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT couple_id FROM users WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- PASSO 4: Recriar TODAS as policies com nomes específicos
-- e colunas qualificadas
-- =============================================

-- =============================================
-- POLICIES PARA: transactions
-- =============================================
DROP POLICY IF EXISTS "transactions_select_own" ON transactions;
DROP POLICY IF EXISTS "transactions_insert_own" ON transactions;
DROP POLICY IF EXISTS "transactions_update_own" ON transactions;
DROP POLICY IF EXISTS "transactions_delete_own" ON transactions;

CREATE POLICY "transactions_select_own" ON transactions
  FOR SELECT USING (transactions.couple_id = get_user_couple_id());

CREATE POLICY "transactions_insert_own" ON transactions
  FOR INSERT WITH CHECK (transactions.couple_id = get_user_couple_id());

CREATE POLICY "transactions_update_own" ON transactions
  FOR UPDATE USING (transactions.couple_id = get_user_couple_id());

CREATE POLICY "transactions_delete_own" ON transactions
  FOR DELETE USING (transactions.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: categories
-- =============================================
DROP POLICY IF EXISTS "categories_select" ON categories;
DROP POLICY IF EXISTS "categories_insert_own" ON categories;
DROP POLICY IF EXISTS "categories_update_own" ON categories;
DROP POLICY IF EXISTS "categories_delete_own" ON categories;

CREATE POLICY "categories_select" ON categories
  FOR SELECT USING (
    categories.couple_id = get_user_couple_id() OR categories.is_default = TRUE
  );

CREATE POLICY "categories_insert_own" ON categories
  FOR INSERT WITH CHECK (categories.couple_id = get_user_couple_id());

CREATE POLICY "categories_update_own" ON categories
  FOR UPDATE USING (categories.couple_id = get_user_couple_id());

CREATE POLICY "categories_delete_own" ON categories
  FOR DELETE USING (categories.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: credit_cards
-- =============================================
DROP POLICY IF EXISTS "credit_cards_select_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_insert_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_update_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_delete_own" ON credit_cards;

CREATE POLICY "credit_cards_select_own" ON credit_cards
  FOR SELECT USING (credit_cards.couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_insert_own" ON credit_cards
  FOR INSERT WITH CHECK (credit_cards.couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_update_own" ON credit_cards
  FOR UPDATE USING (credit_cards.couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_delete_own" ON credit_cards
  FOR DELETE USING (credit_cards.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: properties
-- =============================================
DROP POLICY IF EXISTS "properties_select_own" ON properties;
DROP POLICY IF EXISTS "properties_insert_own" ON properties;
DROP POLICY IF EXISTS "properties_update_own" ON properties;
DROP POLICY IF EXISTS "properties_delete_own" ON properties;

CREATE POLICY "properties_select_own" ON properties
  FOR SELECT USING (properties.couple_id = get_user_couple_id());

CREATE POLICY "properties_insert_own" ON properties
  FOR INSERT WITH CHECK (properties.couple_id = get_user_couple_id());

CREATE POLICY "properties_update_own" ON properties
  FOR UPDATE USING (properties.couple_id = get_user_couple_id());

CREATE POLICY "properties_delete_own" ON properties
  FOR DELETE USING (properties.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: savings_goals
-- =============================================
DROP POLICY IF EXISTS "savings_goals_select_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_insert_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_update_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_delete_own" ON savings_goals;

CREATE POLICY "savings_goals_select_own" ON savings_goals
  FOR SELECT USING (savings_goals.couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_insert_own" ON savings_goals
  FOR INSERT WITH CHECK (savings_goals.couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_update_own" ON savings_goals
  FOR UPDATE USING (savings_goals.couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_delete_own" ON savings_goals
  FOR DELETE USING (savings_goals.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: agenda_events
-- =============================================
DROP POLICY IF EXISTS "agenda_events_select_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_insert_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_update_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_delete_own" ON agenda_events;

CREATE POLICY "agenda_events_select_own" ON agenda_events
  FOR SELECT USING (agenda_events.couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_insert_own" ON agenda_events
  FOR INSERT WITH CHECK (agenda_events.couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_update_own" ON agenda_events
  FOR UPDATE USING (agenda_events.couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_delete_own" ON agenda_events
  FOR DELETE USING (agenda_events.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: shopping_months
-- =============================================
DROP POLICY IF EXISTS "shopping_months_select_own" ON shopping_months;
DROP POLICY IF EXISTS "shopping_months_insert_own" ON shopping_months;

CREATE POLICY "shopping_months_select_own" ON shopping_months
  FOR SELECT USING (shopping_months.couple_id = get_user_couple_id());

CREATE POLICY "shopping_months_insert_own" ON shopping_months
  FOR INSERT WITH CHECK (shopping_months.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: shopping_items (não tem couple_id direto)
-- =============================================
DROP POLICY IF EXISTS "shopping_items_select_own" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_insert_own" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_update_own" ON shopping_items;
DROP POLICY IF EXISTS "shopping_items_delete_own" ON shopping_items;

CREATE POLICY "shopping_items_select_own" ON shopping_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM shopping_months
      WHERE shopping_months.id = shopping_items.shopping_month_id
      AND shopping_months.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "shopping_items_insert_own" ON shopping_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_months
      WHERE shopping_months.id = shopping_items.shopping_month_id
      AND shopping_months.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "shopping_items_update_own" ON shopping_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM shopping_months
      WHERE shopping_months.id = shopping_items.shopping_month_id
      AND shopping_months.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "shopping_items_delete_own" ON shopping_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM shopping_months
      WHERE shopping_months.id = shopping_items.shopping_month_id
      AND shopping_months.couple_id = get_user_couple_id()
    )
  );

-- =============================================
-- POLICIES PARA: tasks
-- =============================================
DROP POLICY IF EXISTS "tasks_select_own" ON tasks;
DROP POLICY IF EXISTS "tasks_insert_own" ON tasks;
DROP POLICY IF EXISTS "tasks_update_own" ON tasks;
DROP POLICY IF EXISTS "tasks_delete_own" ON tasks;

CREATE POLICY "tasks_select_own" ON tasks
  FOR SELECT USING (tasks.couple_id = get_user_couple_id());

CREATE POLICY "tasks_insert_own" ON tasks
  FOR INSERT WITH CHECK (tasks.couple_id = get_user_couple_id());

CREATE POLICY "tasks_update_own" ON tasks
  FOR UPDATE USING (tasks.couple_id = get_user_couple_id());

CREATE POLICY "tasks_delete_own" ON tasks
  FOR DELETE USING (tasks.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: goals
-- =============================================
DROP POLICY IF EXISTS "goals_select_own" ON goals;
DROP POLICY IF EXISTS "goals_insert_own" ON goals;
DROP POLICY IF EXISTS "goals_update_own" ON goals;
DROP POLICY IF EXISTS "goals_delete_own" ON goals;

CREATE POLICY "goals_select_own" ON goals
  FOR SELECT USING (goals.couple_id = get_user_couple_id());

CREATE POLICY "goals_insert_own" ON goals
  FOR INSERT WITH CHECK (goals.couple_id = get_user_couple_id());

CREATE POLICY "goals_update_own" ON goals
  FOR UPDATE USING (goals.couple_id = get_user_couple_id());

CREATE POLICY "goals_delete_own" ON goals
  FOR DELETE USING (goals.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: goal_milestones (não tem couple_id direto)
-- =============================================
DROP POLICY IF EXISTS "goal_milestones_select_own" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_insert_own" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_update_own" ON goal_milestones;
DROP POLICY IF EXISTS "goal_milestones_delete_own" ON goal_milestones;

CREATE POLICY "goal_milestones_select_own" ON goal_milestones
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = goal_milestones.goal_id
      AND goals.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "goal_milestones_insert_own" ON goal_milestones
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = goal_milestones.goal_id
      AND goals.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "goal_milestones_update_own" ON goal_milestones
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = goal_milestones.goal_id
      AND goals.couple_id = get_user_couple_id()
    )
  );

CREATE POLICY "goal_milestones_delete_own" ON goal_milestones
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = goal_milestones.goal_id
      AND goals.couple_id = get_user_couple_id()
    )
  );

-- =============================================
-- POLICIES PARA: installments
-- =============================================
DROP POLICY IF EXISTS "installments_select_own" ON installments;
DROP POLICY IF EXISTS "installments_insert_own" ON installments;

CREATE POLICY "installments_select_own" ON installments
  FOR SELECT USING (installments.couple_id = get_user_couple_id());

CREATE POLICY "installments_insert_own" ON installments
  FOR INSERT WITH CHECK (installments.couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: property_evolution (não tem couple_id direto)
-- =============================================
DROP POLICY IF EXISTS "property_evolution_select_own" ON property_evolution;

CREATE POLICY "property_evolution_select_own" ON property_evolution
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM properties
      WHERE properties.id = property_evolution.property_id
      AND properties.couple_id = get_user_couple_id()
    )
  );

-- =============================================
-- POLICIES PARA: users (perfil próprio)
-- =============================================
DROP POLICY IF EXISTS "users_select_own" ON users;
DROP POLICY IF EXISTS "users_update_own" ON users;
DROP POLICY IF EXISTS "users_insert_own" ON users;

CREATE POLICY "users_select_own" ON users
  FOR SELECT USING (users.id = auth.uid());

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (users.id = auth.uid());

CREATE POLICY "users_insert_own" ON users
  FOR INSERT WITH CHECK (users.id = auth.uid());

-- =============================================
-- POLICIES PARA: couples (mantém a lógica de convite)
-- =============================================
DROP POLICY IF EXISTS "couples_select_member" ON couples;
DROP POLICY IF EXISTS "couples_insert_own" ON couples;
DROP POLICY IF EXISTS "couples_update_member" ON couples;

CREATE POLICY "couples_select_member" ON couples
  FOR SELECT USING (
    couples.partner1_id = auth.uid() 
    OR couples.partner2_id = auth.uid() 
    OR couples.invite_code IS NOT NULL
  );

CREATE POLICY "couples_insert_own" ON couples
  FOR INSERT WITH CHECK (couples.partner1_id = auth.uid());

CREATE POLICY "couples_update_member" ON couples
  FOR UPDATE USING (
    couples.partner1_id = auth.uid() OR couples.partner2_id = auth.uid()
  );

-- =============================================
-- ATIVAR RLS EM TODAS AS TABELAS
-- =============================================
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE agenda_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_months ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE installments ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_evolution ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE couples ENABLE ROW LEVEL SECURITY;

-- Forçar RLS até para usuários com bypass (table owners)
ALTER TABLE transactions FORCE ROW LEVEL SECURITY;
ALTER TABLE categories FORCE ROW LEVEL SECURITY;
ALTER TABLE credit_cards FORCE ROW LEVEL SECURITY;
ALTER TABLE properties FORCE ROW LEVEL SECURITY;
ALTER TABLE savings_goals FORCE ROW LEVEL SECURITY;
ALTER TABLE agenda_events FORCE ROW LEVEL SECURITY;
ALTER TABLE shopping_months FORCE ROW LEVEL SECURITY;
ALTER TABLE shopping_items FORCE ROW LEVEL SECURITY;
ALTER TABLE tasks FORCE ROW LEVEL SECURITY;
ALTER TABLE goals FORCE ROW LEVEL SECURITY;
ALTER TABLE goal_milestones FORCE ROW LEVEL SECURITY;
ALTER TABLE installments FORCE ROW LEVEL SECURITY;
ALTER TABLE property_evolution FORCE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;
ALTER TABLE couples FORCE ROW LEVEL SECURITY;
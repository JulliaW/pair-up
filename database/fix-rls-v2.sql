-- =============================================
-- Correção RLS v2: Resolver ambiguidade de couple_id
-- =============================================

-- Cria função segura para obter couple_id do usuário logado
-- Isso evita ambiguidade "column reference couple_id is ambiguous"
CREATE OR REPLACE FUNCTION get_user_couple_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT couple_id FROM users WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- POLICIES PARA: transactions
-- =============================================
DROP POLICY IF EXISTS "transactions_select_own" ON transactions;
DROP POLICY IF EXISTS "transactions_insert_own" ON transactions;
DROP POLICY IF EXISTS "transactions_update_own" ON transactions;
DROP POLICY IF EXISTS "transactions_delete_own" ON transactions;

CREATE POLICY "transactions_select_own" ON transactions
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "transactions_insert_own" ON transactions
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "transactions_update_own" ON transactions
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "transactions_delete_own" ON transactions
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: categories
-- =============================================
DROP POLICY IF EXISTS "categories_select" ON categories;
DROP POLICY IF EXISTS "categories_insert_own" ON categories;
DROP POLICY IF EXISTS "categories_update_own" ON categories;
DROP POLICY IF EXISTS "categories_delete_own" ON categories;

CREATE POLICY "categories_select" ON categories
  FOR SELECT USING (
    couple_id = get_user_couple_id() OR is_default = TRUE
  );

CREATE POLICY "categories_insert_own" ON categories
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "categories_update_own" ON categories
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "categories_delete_own" ON categories
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: credit_cards
-- =============================================
DROP POLICY IF EXISTS "credit_cards_select_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_insert_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_update_own" ON credit_cards;
DROP POLICY IF EXISTS "credit_cards_delete_own" ON credit_cards;

CREATE POLICY "credit_cards_select_own" ON credit_cards
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_insert_own" ON credit_cards
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_update_own" ON credit_cards
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "credit_cards_delete_own" ON credit_cards
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: properties
-- =============================================
DROP POLICY IF EXISTS "properties_select_own" ON properties;
DROP POLICY IF EXISTS "properties_insert_own" ON properties;
DROP POLICY IF EXISTS "properties_update_own" ON properties;
DROP POLICY IF EXISTS "properties_delete_own" ON properties;

CREATE POLICY "properties_select_own" ON properties
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "properties_insert_own" ON properties
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "properties_update_own" ON properties
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "properties_delete_own" ON properties
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: savings_goals
-- =============================================
DROP POLICY IF EXISTS "savings_goals_select_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_insert_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_update_own" ON savings_goals;
DROP POLICY IF EXISTS "savings_goals_delete_own" ON savings_goals;

CREATE POLICY "savings_goals_select_own" ON savings_goals
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_insert_own" ON savings_goals
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_update_own" ON savings_goals
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "savings_goals_delete_own" ON savings_goals
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: agenda_events
-- =============================================
DROP POLICY IF EXISTS "agenda_events_select_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_insert_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_update_own" ON agenda_events;
DROP POLICY IF EXISTS "agenda_events_delete_own" ON agenda_events;

CREATE POLICY "agenda_events_select_own" ON agenda_events
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_insert_own" ON agenda_events
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_update_own" ON agenda_events
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "agenda_events_delete_own" ON agenda_events
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: shopping_months
-- =============================================
DROP POLICY IF EXISTS "shopping_months_select_own" ON shopping_months;
DROP POLICY IF EXISTS "shopping_months_insert_own" ON shopping_months;

CREATE POLICY "shopping_months_select_own" ON shopping_months
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "shopping_months_insert_own" ON shopping_months
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: tasks
-- =============================================
DROP POLICY IF EXISTS "tasks_select_own" ON tasks;
DROP POLICY IF EXISTS "tasks_insert_own" ON tasks;
DROP POLICY IF EXISTS "tasks_update_own" ON tasks;
DROP POLICY IF EXISTS "tasks_delete_own" ON tasks;

CREATE POLICY "tasks_select_own" ON tasks
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "tasks_insert_own" ON tasks
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "tasks_update_own" ON tasks
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "tasks_delete_own" ON tasks
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: goals
-- =============================================
DROP POLICY IF EXISTS "goals_select_own" ON goals;
DROP POLICY IF EXISTS "goals_insert_own" ON goals;
DROP POLICY IF EXISTS "goals_update_own" ON goals;
DROP POLICY IF EXISTS "goals_delete_own" ON goals;

CREATE POLICY "goals_select_own" ON goals
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "goals_insert_own" ON goals
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

CREATE POLICY "goals_update_own" ON goals
  FOR UPDATE USING (couple_id = get_user_couple_id());

CREATE POLICY "goals_delete_own" ON goals
  FOR DELETE USING (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: installments
-- =============================================
DROP POLICY IF EXISTS "installments_select_own" ON installments;
DROP POLICY IF EXISTS "installments_insert_own" ON installments;

CREATE POLICY "installments_select_own" ON installments
  FOR SELECT USING (couple_id = get_user_couple_id());

CREATE POLICY "installments_insert_own" ON installments
  FOR INSERT WITH CHECK (couple_id = get_user_couple_id());

-- =============================================
-- POLICIES PARA: property_evolution
-- =============================================
DROP POLICY IF EXISTS "property_evolution_select_own" ON property_evolution;

CREATE POLICY "property_evolution_select_own" ON property_evolution
  FOR SELECT USING (
    property_id IN (
      SELECT id FROM properties WHERE couple_id = get_user_couple_id()
    )
  );

-- =============================================
-- POLICIES PARA: users (perfil próprio)
-- =============================================
DROP POLICY IF EXISTS "users_select_own" ON users;
DROP POLICY IF EXISTS "users_update_own" ON users;

CREATE POLICY "users_select_own" ON users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (id = auth.uid());

-- =============================================
-- POLICIES PARA: couples (mantém a lógica de convite)
-- =============================================
DROP POLICY IF EXISTS "couples_select_member" ON couples;
DROP POLICY IF EXISTS "couples_insert_own" ON couples;

CREATE POLICY "couples_select_member" ON couples
  FOR SELECT USING (
    partner1_id = auth.uid() 
    OR partner2_id = auth.uid() 
    OR invite_code IS NOT NULL
  );

CREATE POLICY "couples_insert_own" ON couples
  FOR INSERT WITH CHECK (partner1_id = auth.uid());

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
ALTER TABLE installments FORCE ROW LEVEL SECURITY;
ALTER TABLE property_evolution FORCE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;
ALTER TABLE couples FORCE ROW LEVEL SECURITY;

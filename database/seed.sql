-- =============================================
-- PairUp - Script de Seed para Supabase
-- =============================================
-- Execute este script no SQL Editor do Supabase
-- após criar as tabelas (via migrations ou manualmente)

-- =============================================
-- CATEGORIAS PADRÃO
-- =============================================
INSERT INTO categories (name, type, icon, color, is_default) VALUES
  ('Salário', 'income', 'work', '#43A047', true),
  ('Freelance', 'income', 'computer', '#26A69A', true),
  ('Investimentos', 'income', 'trending_up', '#039BE5', true),
  ('Outras Receitas', 'income', 'attach_money', '#78909C', true),
  ('Alimentação', 'expense', 'restaurant', '#FF7043', true),
  ('Moradia', 'expense', 'home', '#5C6BC0', true),
  ('Transporte', 'expense', 'directions_car', '#AB47BC', true),
  ('Saúde', 'expense', 'local_hospital', '#E53935', true),
  ('Educação', 'expense', 'school', '#FB8C00', true),
  ('Lazer', 'expense', 'sports_esports', '#26A69A', true),
  ('Vestuário', 'expense', 'checkroom', '#7E57C2', true),
  ('Assinaturas', 'expense', 'subscriptions', '#039BE5', true),
  ('Cartão de Crédito', 'expense', 'credit_card', '#E53935', true),
  ('Serviços', 'expense', 'build', '#78909C', true),
  ('Impostos', 'expense', 'receipt', '#1D1D1D', true),
  ('Mercado', 'expense', 'shopping_cart', '#FFA726', true),
  ('Presentes', 'expense', 'card_giftcard', '#EC407A', true),
  ('Outras Despesas', 'expense', 'more_horiz', '#9E9E9E', true)
ON CONFLICT DO NOTHING;

-- =============================================
-- POLÍTICAS RLS (Row Level Security)
-- =============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE agenda_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_months ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE installments ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_evolution ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;

-- =============================================
-- POLÍTICAS DE USUÁRIOS
-- =============================================

-- Usuários: cada um pode ver/editar apenas seu próprio registro
CREATE POLICY "users_select_own" ON users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "users_insert_own" ON users
  FOR INSERT WITH CHECK (id = auth.uid());

-- =============================================
-- POLÍTICAS DE COUPLES
-- =============================================

CREATE POLICY "couples_select_member" ON couples
  FOR SELECT USING (
    partner1_id = auth.uid() OR partner2_id = auth.uid()
  );

CREATE POLICY "couples_update_member" ON couples
  FOR UPDATE USING (
    partner1_id = auth.uid() OR partner2_id = auth.uid()
  );

CREATE POLICY "couples_insert_own" ON couples
  FOR INSERT WITH CHECK (partner1_id = auth.uid());

-- =============================================
-- POLÍTICA GENÉRICA PARA TABELAS VINCULADAS AO COUPLE
-- =============================================

-- Função auxiliar para verificar se o usuário pertence ao couple
-- (criada no schema public pois o Supabase não permite criar no schema auth)
CREATE OR REPLACE FUNCTION public.is_couple_member(couple_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND couple_id = $1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Política genérica: SELECT
-- Aplicar para: agenda_events, shopping_months, shopping_items, tasks,
-- goals, transactions, credit_cards, installments, properties,
-- property_evolution, savings_goals

-- Políticas para tabelas com couple_id direto
DO $$
DECLARE
  table_name TEXT;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[
    'agenda_events', 'shopping_months', 'tasks',
    'goals', 'transactions', 'credit_cards', 'installments',
    'properties', 'savings_goals'
  ]
  LOOP
    EXECUTE format(
      'CREATE POLICY "couple_data_select" ON %I
        FOR SELECT USING (public.is_couple_member(couple_id))',
      table_name
    );
    EXECUTE format(
      'CREATE POLICY "couple_data_insert" ON %I
        FOR INSERT WITH CHECK (public.is_couple_member(couple_id))',
      table_name
    );
    EXECUTE format(
      'CREATE POLICY "couple_data_update" ON %I
        FOR UPDATE USING (public.is_couple_member(couple_id))',
      table_name
    );
    EXECUTE format(
      'CREATE POLICY "couple_data_delete" ON %I
        FOR DELETE USING (public.is_couple_member(couple_id))',
      table_name
    );
  END LOOP;
END;
$$;

-- Políticas para shopping_items (não tem couple_id direto, usa shopping_month_id)
CREATE POLICY "shopping_items_select" ON shopping_items
  FOR SELECT USING (
    public.is_couple_member(
      (SELECT sm.couple_id FROM shopping_months sm WHERE sm.id = shopping_items.shopping_month_id)
    )
  );
CREATE POLICY "shopping_items_insert" ON shopping_items
  FOR INSERT WITH CHECK (
    public.is_couple_member(
      (SELECT sm.couple_id FROM shopping_months sm WHERE sm.id = shopping_items.shopping_month_id)
    )
  );
CREATE POLICY "shopping_items_update" ON shopping_items
  FOR UPDATE USING (
    public.is_couple_member(
      (SELECT sm.couple_id FROM shopping_months sm WHERE sm.id = shopping_items.shopping_month_id)
    )
  );
CREATE POLICY "shopping_items_delete" ON shopping_items
  FOR DELETE USING (
    public.is_couple_member(
      (SELECT sm.couple_id FROM shopping_months sm WHERE sm.id = shopping_items.shopping_month_id)
    )
  );

-- Políticas para goal_milestones (não tem couple_id direto, usa goal_id)
CREATE POLICY "goal_milestones_select" ON goal_milestones
  FOR SELECT USING (
    public.is_couple_member(
      (SELECT g.couple_id FROM goals g WHERE g.id = goal_milestones.goal_id)
    )
  );
CREATE POLICY "goal_milestones_insert" ON goal_milestones
  FOR INSERT WITH CHECK (
    public.is_couple_member(
      (SELECT g.couple_id FROM goals g WHERE g.id = goal_milestones.goal_id)
    )
  );
CREATE POLICY "goal_milestones_update" ON goal_milestones
  FOR UPDATE USING (
    public.is_couple_member(
      (SELECT g.couple_id FROM goals g WHERE g.id = goal_milestones.goal_id)
    )
  );
CREATE POLICY "goal_milestones_delete" ON goal_milestones
  FOR DELETE USING (
    public.is_couple_member(
      (SELECT g.couple_id FROM goals g WHERE g.id = goal_milestones.goal_id)
    )
  );

-- Políticas para property_evolution (não tem couple_id direto, usa property_id)
CREATE POLICY "property_evolution_select" ON property_evolution
  FOR SELECT USING (
    public.is_couple_member(
      (SELECT p.couple_id FROM properties p WHERE p.id = property_evolution.property_id)
    )
  );
CREATE POLICY "property_evolution_insert" ON property_evolution
  FOR INSERT WITH CHECK (
    public.is_couple_member(
      (SELECT p.couple_id FROM properties p WHERE p.id = property_evolution.property_id)
    )
  );
CREATE POLICY "property_evolution_update" ON property_evolution
  FOR UPDATE USING (
    public.is_couple_member(
      (SELECT p.couple_id FROM properties p WHERE p.id = property_evolution.property_id)
    )
  );
CREATE POLICY "property_evolution_delete" ON property_evolution
  FOR DELETE USING (
    public.is_couple_member(
      (SELECT p.couple_id FROM properties p WHERE p.id = property_evolution.property_id)
    )
  );

-- Categorias: vê as próprias ou as padrão
CREATE POLICY "categories_select" ON categories
  FOR SELECT USING (
  couple_id IS NULL OR public.is_couple_member(couple_id)
  );

-- =============================================
-- TRIGGER: Criar usuário na tabela users após signup
-- =============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop se já existir e recria
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- =============================================

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_agenda_events_couple_date
  ON agenda_events(couple_id, event_date);

CREATE INDEX IF NOT EXISTS idx_shopping_items_month
  ON shopping_items(shopping_month_id);

CREATE INDEX IF NOT EXISTS idx_tasks_couple_status
  ON tasks(couple_id, status);

CREATE INDEX IF NOT EXISTS idx_transactions_couple_date
  ON transactions(couple_id, date);

CREATE INDEX IF NOT EXISTS idx_transactions_category
  ON transactions(category_id);

CREATE INDEX IF NOT EXISTS idx_goals_couple
  ON goals(couple_id);

CREATE INDEX IF NOT EXISTS idx_property_evolution_property
  ON property_evolution(property_id);

-- Índice para buscar usuário por couple_id
CREATE INDEX IF NOT EXISTS idx_users_couple
  ON users(couple_id);
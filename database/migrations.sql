-- =============================================
-- PairUp - Migration Inicial: Criação de Tabelas
-- =============================================
-- Execute este script no SQL Editor do Supabase

-- =============================================
-- EXTENSÕES NECESSÁRIAS
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- IMPORTANTE: Ordem de criação para evitar
-- erro de foreign key inexistente
-- =============================================

-- 1. couples (sem FK para users ainda)
CREATE TABLE IF NOT EXISTS couples (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner1_id UUID,
  partner2_id UUID,
  invite_code TEXT UNIQUE,
  relationship_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. users (com FK para couples e auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  name TEXT,
  avatar_url TEXT,
  couple_id UUID REFERENCES couples(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Adicionar FKs de couples para users
ALTER TABLE couples ADD CONSTRAINT fk_couples_partner1
  FOREIGN KEY (partner1_id) REFERENCES users(id);

ALTER TABLE couples ADD CONSTRAINT fk_couples_partner2
  FOREIGN KEY (partner2_id) REFERENCES users(id);

-- 4. agenda_events
CREATE TABLE IF NOT EXISTS agenda_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  event_date DATE NOT NULL,
  event_time TIME,
  recurrence TEXT DEFAULT 'none',
  responsible_user_id UUID REFERENCES users(id),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. shopping_months
CREATE TABLE IF NOT EXISTS shopping_months (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  total_items INTEGER DEFAULT 0,
  purchased_items INTEGER DEFAULT 0,
  is_closed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(couple_id, month, year)
);

-- 6. shopping_items
CREATE TABLE IF NOT EXISTS shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shopping_month_id UUID REFERENCES shopping_months(id) NOT NULL,
  name TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  category TEXT,
  notes TEXT,
  status TEXT DEFAULT 'pending',
  purchased_by UUID REFERENCES users(id),
  purchased_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. tasks
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT DEFAULT 'medium',
  responsible_user_id UUID REFERENCES users(id),
  due_date DATE,
  status TEXT DEFAULT 'todo',
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. goals
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  target_amount DECIMAL(11,2),
  current_amount DECIMAL(11,2) DEFAULT 0,
  target_date DATE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. goal_milestones
CREATE TABLE IF NOT EXISTS goal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID REFERENCES goals(id) NOT NULL,
  title TEXT NOT NULL,
  target_value DECIMAL(11,2),
  achieved BOOLEAN DEFAULT FALSE,
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. categories
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  name TEXT NOT NULL,
  card_limit DECIMAL(11,2) NOT NULL,
  closing_day INTEGER NOT NULL,
  due_day INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. installments
CREATE TABLE IF NOT EXISTS installments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID,
  couple_id UUID REFERENCES couples(id) NOT NULL,
  card_id UUID REFERENCES credit_cards(id) NOT NULL,
  total_amount DECIMAL(11,2) NOT NULL,
  total_installments INTEGER NOT NULL,
  current_installment INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. properties
CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  name TEXT DEFAULT 'Apartamento',
  total_value DECIMAL(11,2),
  financed_amount DECIMAL(11,2) DEFAULT 202055.90,
  down_payment DECIMAL(11,2),
  interest_rate DECIMAL(5,2) DEFAULT 7.66,
  monthly_payment DECIMAL(11,2) DEFAULT 1500,
  remaining_balance DECIMAL(11,2) DEFAULT 202055.90,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. property_evolution
CREATE TABLE IF NOT EXISTS property_evolution (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID REFERENCES properties(id) NOT NULL,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  paid_amount DECIMAL(11,2) DEFAULT 0,
  extra_amortization DECIMAL(11,2) DEFAULT 0,
  interest_paid DECIMAL(11,2) DEFAULT 0,
  amortized_value DECIMAL(11,2) DEFAULT 0,
  remaining_balance DECIMAL(11,2),
  total_invested DECIMAL(11,2) DEFAULT 0,
  property_value_estimate DECIMAL(11,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(property_id, month, year)
);

-- 15. savings_goals
CREATE TABLE IF NOT EXISTS savings_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  name TEXT NOT NULL,
  target_amount DECIMAL(11,2) NOT NULL,
  current_amount DECIMAL(11,2) DEFAULT 0,
  target_date DATE,
  is_locked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. transactions (por último, pois depende de várias outras tabelas)
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID REFERENCES couples(id) NOT NULL,
  type TEXT NOT NULL,
  amount DECIMAL(11,2) NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  category_id UUID REFERENCES categories(id),
  card_id UUID REFERENCES credit_cards(id),
  installment_of UUID REFERENCES installments(id),
  property_related BOOLEAN DEFAULT FALSE,
  property_id UUID REFERENCES properties(id),
  is_recurring BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. FK de installments para transactions (cíclica, feita após ambas existirem)
ALTER TABLE installments ADD CONSTRAINT fk_installments_transaction
  FOREIGN KEY (transaction_id) REFERENCES transactions(id);
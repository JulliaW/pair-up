-- =============================================
-- PairUp - Migration V2: Categorias de Apartamento
-- =============================================

-- Adiciona coluna scope na tabela categories
ALTER TABLE categories ADD COLUMN IF NOT EXISTS scope TEXT DEFAULT 'general';

-- Insere categorias padrão para apartamento (se não existirem)
INSERT INTO categories (name, type, icon, color, scope, is_default)
SELECT * FROM (VALUES
  ('Entrada', 'expense', 'payment', '#0d9488', 'property', true),
  ('Juros Obra', 'expense', 'trending_up', '#dc2626', 'property', true),
  ('Financiamento', 'expense', 'account_balance', '#2563eb', 'property', true)
) AS v(name, type, icon, color, scope, is_default)
WHERE NOT EXISTS (
  SELECT 1 FROM categories c
  WHERE c.name = v.name AND c.scope = 'property'
);
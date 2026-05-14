-- =============================================
-- PairUp - Script de Importação da Planilha
-- =============================================
-- ATENÇÃO: Substitua os valores abaixo pelos seus dados
-- =============================================

-- 1. Primeiro, descubra seu couple_id e user_id:
-- SELECT id AS couple_id FROM couples LIMIT 1;
-- SELECT id AS user_id FROM users LIMIT 1;

-- 2. Defina as variáveis (substitua pelos valores reais)
-- Exemplo:
-- couple_id: '123e4567-e89b-12d3-a456-426614174000'
-- user_id:  '123e4567-e89b-12d3-a456-426614174001'

-- =============================================
-- ABA "Entrada" — Categoria: Entrada
-- Formato: data, valor
-- =============================================
-- Substitua 'SEU_COUPLE_ID' e 'SEU_USER_ID'
--
-- INSERT INTO transactions (couple_id, type, amount, description, date, category_id, property_related, created_by)
-- SELECT
--   'SEU_COUPLE_ID'::uuid,
--   'expense',
--   VALOR_AQUI,  -- ex: 15000.00
--   'Entrada apartamento',
--   'DATA_AQUI'::date,  -- ex: '2023-03-15'
--   (SELECT id FROM categories WHERE name = 'Entrada' AND scope = 'property' LIMIT 1),
--   true,
--   'SEU_USER_ID'::uuid;
--
-- Repita para cada linha da planilha...

-- =============================================
-- EXEMPLO PRÁTICO (substitua os UUIDs e valores):
-- =============================================

-- === ENTRADA ===
INSERT INTO transactions (couple_id, type, amount, description, date, category_id, property_related, created_by)
VALUES
  ('SEU_COUPLE_ID'::uuid, 'expense', 15000.00, 'Entrada apartamento - 1ª parcela', '2023-03-15'::date, (SELECT id FROM categories WHERE name = 'Entrada' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid),
  ('SEU_COUPLE_ID'::uuid, 'expense', 10000.00, 'Entrada apartamento - 2ª parcela', '2023-06-20'::date, (SELECT id FROM categories WHERE name = 'Entrada' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid),
  ('SEU_COUPLE_ID'::uuid, 'expense', 8000.00,  'Entrada apartamento - 3ª parcela', '2024-01-10'::date, (SELECT id FROM categories WHERE name = 'Entrada' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid);

-- === JUROS OBRA ===
INSERT INTO transactions (couple_id, type, amount, description, date, category_id, property_related, created_by)
VALUES
  ('SEU_COUPLE_ID'::uuid, 'expense', 1200.00, 'Juros obra - jan/2023',  '2023-01-15'::date, (SELECT id FROM categories WHERE name = 'Juros Obra' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid),
  ('SEU_COUPLE_ID'::uuid, 'expense', 1200.00, 'Juros obra - fev/2023', '2023-02-15'::date, (SELECT id FROM categories WHERE name = 'Juros Obra' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid),
  ('SEU_COUPLE_ID'::uuid, 'expense', 1200.00, 'Juros obra - mar/2023', '2023-03-15'::date, (SELECT id FROM categories WHERE name = 'Juros Obra' AND scope = 'property' LIMIT 1), true, 'SEU_USER_ID'::uuid);

-- =============================================
-- Se preferir, use o formato abaixo para copiar
-- da planilha e colar (mais fácil para várias linhas):
-- =============================================

-- Copie os dados da planilha para este formato:
-- ('SEU_COUPLE_ID', 'expense', VALOR, 'Descrição', 'DATA', true, 'SEU_USER_ID'),

-- Depois use:
-- INSERT INTO transactions (couple_id, type, amount, description, date, property_related, created_by, category_id)
-- VALUES
--   ... (cole aqui) ...;

-- Lembrando que category_id você pega com:
-- SELECT id, name FROM categories WHERE scope = 'property';
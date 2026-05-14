-- =============================================
-- PairUp - Migration V3: Apartamento
-- =============================================

-- Adiciona campo para total da entrada (valor combinado com a construtora)
ALTER TABLE properties ADD COLUMN IF NOT EXISTS down_payment_total DECIMAL(11,2) DEFAULT 0;

-- Adiciona campo para total de juros de obra estimado
ALTER TABLE properties ADD COLUMN IF NOT EXISTS interest_work_total DECIMAL(11,2) DEFAULT 0;
-- =============================================
-- Correção: Permitir busca de convite por invite_code
-- =============================================
-- O Usuário 2 precisa conseguir buscar um couple pelo
-- invite_code mesmo sem ser membro ainda.

-- Remove a policy genérica antiga de couples
DROP POLICY IF EXISTS "couples_select_member" ON couples;

-- Cria nova policy que permite:
-- 1. Membros do casal verem o registro
-- 2. Qualquer um logado buscar por invite_code (para aceitar convite)
CREATE POLICY "couples_select_member" ON couples
  FOR SELECT USING (
    partner1_id = auth.uid() 
    OR partner2_id = auth.uid() 
    OR invite_code IS NOT NULL  -- permite buscar por código
  );

-- Também garante que a inserção ainda funciona
CREATE POLICY "couples_insert_own" ON couples
  FOR INSERT WITH CHECK (partner1_id = auth.uid());
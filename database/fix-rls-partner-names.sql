-- =============================================
-- Correção RLS: Permitir que parceiros vejam os nomes um do outro
-- =============================================
-- A RLS atual (users_select_own) só permite SELECT do próprio usuário.
-- Isso impede que JOINs para obter partner1_name/partner2_name funcionem,
-- pois o Supabase aplica RLS também nas relações (joins).
--
-- Solução: Adicionar policy que permite SELECT de qualquer usuário
-- que pertença ao mesmo couple_id.
-- 
-- IMPORTANTE: Usamos get_user_couple_id() em vez de subquery na tabela users
-- para evitar recursão infinita na policy.

DROP POLICY IF EXISTS "users_select_couple_members" ON users;

CREATE POLICY "users_select_couple_members" ON users
  FOR SELECT USING (
    users.id = auth.uid()
    OR (
      users.couple_id IS NOT NULL
      AND users.couple_id = get_user_couple_id()
    )
  );

-- Nota: A policy "users_select_own" ainda existe e cobre o caso base.
-- Esta nova policy é adicional (OR) e permite o caso do parceiro.
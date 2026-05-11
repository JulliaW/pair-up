const routes = [
  // Rota pública - Login
  {
    path: '/login',
    name: 'login',
    component: () => import('pages/LoginPage.vue'),
    meta: { requiresAuth: false }
  },
  // Rota para aceitar convite (pública - pode ser acessada sem login)
  {
    path: '/aceitar-convite',
    name: 'aceitar-convite',
    component: () => import('pages/AcceptInvitePage.vue'),
    meta: { requiresAuth: false }
  },

  // Rotas protegidas (requer autenticação + casal)
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: () => import('pages/IndexPage.vue')
      },
      {
        path: 'agenda',
        name: 'agenda',
        component: () => import('pages/AgendaPage.vue')
      },
      {
        path: 'compras',
        name: 'compras',
        component: () => import('pages/ShoppingPage.vue')
      },
      {
        path: 'tarefas',
        name: 'tarefas',
        component: () => import('pages/TasksPage.vue')
      },
      {
        path: 'metas',
        name: 'metas',
        component: () => import('pages/GoalsPage.vue')
      },
      {
        path: 'financas',
        name: 'financas',
        component: () => import('pages/FinancePage.vue')
      },
      {
        path: 'financas/transacoes',
        name: 'transacoes',
        component: () => import('pages/Finance/TransactionsPage.vue')
      },
      {
        path: 'financas/cartoes',
        name: 'cartoes',
        component: () => import('pages/Finance/CreditCardsPage.vue')
      },
      {
        path: 'financas/apartamento',
        name: 'apartamento',
        component: () => import('pages/Finance/ApartmentPage.vue')
      },
      {
        path: 'financas/cofrinho',
        name: 'cofrinho',
        component: () => import('pages/Finance/SavingsPage.vue')
      },
      {
        path: 'convidar',
        name: 'convidar',
        component: () => import('pages/InvitePage.vue')
      }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
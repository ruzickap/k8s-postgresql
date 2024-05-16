module.exports = {
  title: 'Kubernetes + PostgreSQL',
  description: 'Kubernetes + PostgreSQL',
  base: '/k8s-postgresql/',
  head: [
    ['link', { rel: 'icon', href: 'https://raw.githubusercontent.com/kubernetes/kubernetes/d9a58a39b69a0eaec5797e0f7a0f9472b4829ab0/logo/logo.svg' }]
  ],
  themeConfig: {
    displayAllHeaders: true,
    lastUpdated: true,
    repo: 'ruzickap/k8s-postgresql',
    docsDir: 'docs',
    editLinks: true,
    logo: 'https://raw.githubusercontent.com/kubernetes/kubernetes/d9a58a39b69a0eaec5797e0f7a0f9472b4829ab0/logo/logo.svg',
    nav: [
      { text: 'Home', link: '/' },
      {
        text: 'Links',
        items: [
          { text: 'CrunchyData PostgreSQL Operator', link: 'https://github.com/CrunchyData/postgres-operator' },
          { text: 'Zalando PostgreSQL Operator', link: 'https://github.com/zalando/postgres-operator' }
        ]
      }
    ],
    sidebar: [
      '/',
      '/part-01/',
      '/part-02/',
      '/part-03/'
    ]
  },
  plugins: [
    ['@vuepress/medium-zoom'],
    ['@vuepress/back-to-top'],
    ['reading-progress'],
    ['smooth-scroll'],
    ['seo']
  ]
}

import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Server Config",
  description: "A VitePress Site",
  lastUpdated: true,
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Examples', link: '/markdown-examples' }
    ],

    sidebar: [
      {
        text: 'Examples',
        items: [
          { text: 'Markdown Examples', link: '/markdown-examples' },
          { text: 'Runtime API Examples', link: '/api-examples' },

        ]
      },
        {
          text: "Steps",
          items: [
            { text: '00_cloudflare_dns', link: '/00_cloudflare_dns' },
            { text: '01_add_unprivileged_user', link: '/01_add_unprivileged_user' },
            { text: '02_ssh_keys', link: '/02_ssh_keys' },
            { text: '03_ssh_security_settings', link: '/03_ssh_security_settings' },
            { text: '04_ssh_totp', link: '/04_ssh_totp' },
            { text: '05_msmtp', link: '/05_msmtp' },
            { text: '06_auto_updates', link: '/06_auto_updates' },
            { text: '07_install_software', link: '/07_install_software' },
            { text: '08_ufw', link: '/08_ufw' },
            { text: '09_ufw_cloudflare', link: '/09_ufw_cloudflare' },
            { text: '10_psad', link: '/10_psad' },
            { text: '11_fail2ban', link: '/11_fail2ban' },
            { text: '12_bash_config', link: '/12_bash_config' },
            { text: '13_wireguard', link: '/13_wireguard' },
            { text: '14_docker', link: '/14_docker' },
            { text: '15_docker_network', link: '/15_docker_network' },
            { text: '16_portainer', link: '/16_portainer' },
            { text: '17_nginx_proxy_manager', link: '/17_nginx_proxy_manager' },
            { text: '18_flame', link: '/18_flame' },
            { text: '19_watchtower', link: '/19_watchtower' },
          ]
        }
    ],

  }
})

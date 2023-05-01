import {defineConfig} from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "Server Config",
    description: "A VitePress Site",
    lastUpdated: true,
    base: '/server-config/',
//	markdown: {
//		lineNumbers: true,
//	},
    themeConfig: {
        aside: true,
        outline: [2, 3],
        socialLinks: [
            {icon: 'github', link: 'https://github.com/vuejs/vitepress'},
        ],
        footer: {
            message: 'Created by nikita-t1.',
//            copyright: ''
        },
        // https://vitepress.dev/reference/default-theme-config
        nav: [
            {text: 'Setup', link: '/steps/overview'},
            {text: 'Container', link: '/container/overview'},
        ],
        sidebar: {
            '/steps/': [
                {
                    text: "Steps",
                    items: [
                        {text: 'Overview', link: '/steps/overview'},
                        {text: 'Cloudflare DNS', link: '/steps/00_cloudflare_dns'},
                        {text: 'Unprivileged User', link: '/steps/01_add_unprivileged_user'},
                        {text: 'Login with SSH Keys', link: '/steps/02_ssh_keys'},
                        {text: 'Configure SSH Settings', link: '/steps/03_ssh_security_settings'},
                        {text: 'MFA for SSH', link: '/steps/04_ssh_totp'},
                        {text: 'SMTP Mail Server', link: '/steps/05_msmtp'},
                        {text: 'Unattended Updates', link: '/steps/06_auto_updates'},
                        {text: 'Awesome Shell', link: '/steps/07_install_software'},
                        {text: 'Uncomplicated Firewall', link: '/steps/08_ufw'},
                        {text: 'Cloudflare WAF', link: '/steps/09_ufw_cloudflare'},
                        {text: 'Port Scan Attack Detector', link: '/steps/10_psad'},
                        {text: 'Fail2ban', link: '/steps/11_fail2ban'},
                        {text: '.bashrc File', link: '/steps/12_bash_config'},
                        {text: 'WireGuard VPN', link: '/steps/13_wireguard'},
                        {text: 'Docker', link: '/steps/14_docker'},
                        {text: 'Docker Network', link: '/steps/15_docker_network'},
                        {text: 'Portainer', link: '/steps/16_portainer'},
                    ],
                },
                {
                    text: "Bash Script",
                    link: "/bash_script",
                },
            ],
        },
    },
})


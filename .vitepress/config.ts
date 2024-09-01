import {defineConfig} from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "Server Config",
    description: "A VitePress Site",
    lastUpdated: true,
//	markdown: {
//		lineNumbers: true,
//	},
    themeConfig: {
        aside: true,
        outline: [2, 3],
        socialLinks: [
            {icon: 'github', link: 'https://github.com/nikita-t1/server-config'},
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
                {text: 'Overview', link: '/steps/overview'},
                {
                    text: "Steps",
                    items: [
                        {text: 'Cloudflare DNS', link: '/steps/cloudflare_dns'},
                        {text: 'Unprivileged User', link: '/steps/add_unprivileged_user'},
                        {
                            text: 'Secure Shell (SSH)', items: [
                                {text: 'Login with SSH Keys', link: '/steps/ssh_keys'},
                                {text: 'Configure SSH Settings', link: '/steps/ssh_security_settings'},
                                {text: 'TOTP for SSH', link: '/steps/ssh_totp'},
                            ]
                        },
                        {text: 'Uncomplicated Firewall', link: '/steps/ufw'},
                        {text: 'Cloudflare WAF', link: '/steps/ufw_cloudflare'},
                        {text: 'SMTP Mail Server', link: '/steps/msmtp'},
                        {text: 'Unattended Updates', link: '/steps/auto_updates'},
                        {text: 'Port Scan Attack Detector', link: '/steps/psad'},
                        {text: 'Fail2ban', link: '/steps/fail2ban'},
                        {text: 'WireGuard VPN', link: '/steps/wireguard'},
                        {text: 'Awesome Shell', link: '/steps/install_software'},
                        {text: '.bashrc File', link: '/steps/bash_config'},
                        {text: 'Docker', link: '/steps/docker'},
                        {text: 'Portainer', link: '/steps/portainer'},
                    ],
                },
                {
                    text: "Bash Script",
                    link: "/steps/bash_script",
                },
            ],
            '/container/': [
                {
                    text: "Overview",
                    link: '/container/overview',
                },
                {
                    text: "Container",
                    items: [
                        {text: 'Traefik', link: '/container/traefik'},
                    ],
                },
            ],
        },
    },
})


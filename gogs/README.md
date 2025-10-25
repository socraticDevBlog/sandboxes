![DigitalOcean](https://img.shields.io/badge/DigitalOcean-%230167ff.svg?style=for-the-badge&logo=digitalOcean&logoColor=white)![podman](https://img.shields.io/badge/podman-892CA0?style=for-the-badge&logo=podman&logoColor=white)![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)



# Gogs is a self-hosted git platform sponsored by Digital Ocean

these are the steps I successfully took to host Gogs on my linux Debian VPS

## Container form factor

|                 |                               |
| --------------- | ----------------------------- |
| runtime         | podman                        |
| database engine | sqlite                        |
| storage         | podman volume                 |
| web server      | nginx                         |
| TLS certs       | self-signed with Lets Encrypt |

### 0. make it run

```bash
podman pull docker.io/gogs/gogs

podman volume create gogs-data
# podman volume will get stored at: ~/.local/share/containers/storage/volumes/gogs-data

podman run -d --name=gogs -p 10022:10022  -p 10880:3000 -e "RUN_CROND=true" -v gogs-data:/data  docker.io/gogs/gogs
```

### 1. setup nginx reverse proxy

```bash
sudo apt update

sudo apt install -y nginx certbot python3-certbot-nginx
```

### 2. create an nginx configuration

```bash
sudo vi /etc/nginx/sites-available/gogs
```

paste configuration below in this new files

```nginx
server {
    listen 80;
    server_name <your_domain>;

    location / {
        proxy_pass http://localhost:10880;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

enable the site

```bash
sudo ln -s /etc/nginx/sites-available/gogs /etc/nginx/sites-enabled/

sudo nginx -t

sudo systemctl reload nginx
```

make sure port 80 and port 443 are open

```bash
sudo ufw allow 80/tcp

sudo ufw allow 443/tcp
```

get TLS certificates

```bash
sudo certbot --nginx -d yourdomain.com
```

Follow the prompts. Certbot will automatically:
- Get an SSL certificate from Let's Encrypt
- Configure HTTPS in your Nginx config
- Set up automatic HTTP to HTTPS redirect

### 6. Access Your Site

Now you can access Gogs at:
```
https://yourdomain.com
```

### 7. Important Notes
>
>The TSL certificate will auto-renew
>
>You no longer need to expose port 10880 publicly (only nginx needs to access
>it locally)
>   
>You can remove the public firewall rules for 10880 if you want
>
>Keep port 10022 open if you want Git SSH access
>

## notes


## sources

[Docker for Gogs](https://github.com/gogs/gogs/tree/main/docker)

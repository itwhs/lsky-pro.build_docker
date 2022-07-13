# Lsky-Pro Docker镜像

每天自动拉取最新代码构建Docker镜像

## 使用方法

```docker
docker run -itd --name=lsky \
--restart=always \
-v /var/www/lskydata:/var/www/html \
-p 5479:80 \
qingjiubaba/lsky-pro:latest
```

## 反代HTTPS

```bash
放一个nginx反向代理的虚拟主机配置,只需要修改'***'为你自己主机相关路径和域名即可
cat >/etc/nginx/conf.d/lsky.conf<<'END'
server {
        # SSL
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ***;
        server_tokens off;
        charset utf-8;
        client_max_body_size 100M;
        ##防止搜索引擎收录
        if ($http_user_agent ~* "qihoobot|Baiduspider|Googlebot|Googlebot-Mobile|Googlebot-Image|Mediapartners-Google|Adsbot-Google|Feedfetcher-Google|Yahoo! Slurp|Yahoo! Slurp China|YoudaoBot|Sosospider|Sogou spider|Sogou web spider|MSNBot|ia_archiver|Tomato Bot|^$") {
            return 404;
            }
        error_page 497 https://$host$request_uri;

        if ($scheme = http) {
            return 301 https://$host$request_uri;
        }
        #启用HSTS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;preload" always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options SAMEORIGIN always;
        add_header Referrer-Policy 'strict-origin-when-cross-origin';

        ssl_prefer_server_ciphers on;
        ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;

        ssl_certificate /root/.acme.sh/***/fullchain.cer;
        ssl_certificate_key /root/.acme.sh/***/***.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        keepalive_timeout 120;
        error_log  /var/log/nginx/lsky.error.log;
        access_log /var/log/nginx/lsky.access.log;
        gzip on;
        gzip_vary on;
        gzip_comp_level 9;

        location / {
            root /usr/share/nginx/html;
            #index index.html index.htm;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Port $server_port;
            proxy_pass http://localhost:5479;
        }
}
END
```
如果使用了Nginx反代后，如果出现无法加载图片的问题，可以根据原项目 [#317](https://github.com/lsky-org/lsky-pro/issues/317) 执行以下指令来手动修改容器内`AppServiceProvider.php`文件对于HTTPS的支持

***Tips：将lsky改为自己容器的名字***

```bash
docker exec -it lsky sed -i '32 a \\\Illuminate\\Support\\Facades\\URL::forceScheme('"'"'https'"'"');' /var/www/html/app/Providers/AppServiceProvider.php
```

## Docker-Compose部署参考

使用`MySQL`来作为数据库的话可以参考原项目 [#256](https://github.com/lsky-org/lsky-pro/issues/256) 来创建`docker-compose.yaml`，参考内容如下：

```yaml
version: '3'
services:
  lskypro:
    image: qingjiubaba/lsky-pro:latest
    restart: unless-stopped
    hostname: lsky
    container_name: lsky
    volumes:
      - /var/www/lskydata:/var/www/html
    ports:
      - "5479:80"
    networks:
      - lsky-net

  mysql-lsky:
    image: mysql:5.7.22
    restart: unless-stopped
    # 主机名，可作为子网域名填入安装引导当中
    hostname: mysql-lsky
    # 容器名称
    container_name: mysql-lsky
    # 修改加密规则
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - /data/lsky/mysql/data:/var/lib/mysql
      - /data/lsky/mysql/conf:/etc/mysql
      - /data/lsky/mysql/log:/var/log/mysql
    environment:
      MYSQL_ROOT_PASSWORD: lAsWjb6rzSzENUYg # 数据库root用户密码
      MYSQL_DATABASE: lsky-data # 给lsky-pro用的数据库名称
    networks:
      - lsky-net

networks:
  lsky-net:
```

原项目：[☁️兰空图床(Lsky Pro) - Your photo album on the cloud.](https://github.com/lsky-org/lsky-pro)

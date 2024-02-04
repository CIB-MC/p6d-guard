# What's this?
Amon2-based nginx IP whitelist management tool for Palworld.
(Maybe you can use other games!)

# Prerequest
- Linux with `p6d-guard` user
- systemd
- Perl v5.38.2 with perlbrew
- Perl Carton module (for Amon2)
- nginx with stream module
- Palworld dedicated server (or other game server, etc.)

# How to use
You can create p6d-guard member by using a script located in `script_admin` dir as below.
```
PLACK_ENV=production ~/P6dGuard/script/env ~/P6dGuard/script_admin/create_member.pl
```

Create systemd service as `p6d-guard.service` file, enable and start the service.

Please allow p6d-guard user to execute `sudo nginx -t` and `sudo systemctl reload nginx.service`.

You can change commands to use by editing a file in `Config` dir. 

You can use auto-generated nginx model file in nginx.conf as description in below.

(Don't forget to change Palworld server port and `deny all;` at last!)
```
stream {
      upstream palworld {
            server 127.0.0.1:8212;
      } 

      server {
            listen 8211 udp;
            proxy_pass palworld;
            include /home/p6d-guard/P6dGuard/nginx/allow_ips.model; 
            deny all;
      }
}
```

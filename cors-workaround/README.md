# CORS Workaround

A `docker-compose` setup to run a local instance from language-tool server in a Firefox extension compatible way.

This configuration solves the https://github.com/Erikvl87/docker-languagetool/issues/40 problem (LT's Firefox extension refuses to connect to the local server because the CORS directives are not configured correctly).

The `docker-compose.yml` file builds a minimal image based on NGINX Alpine and configures it to proxy the LT container with the CORS configuration and port that the extension expects.

It also pipes NGINX logs to `stdout` for an easier debugging.



### Structure
```
├── docker-compose.yml
├── nginx
│   ├── Dockerfile
│   └── nginx.conf
└── README.md
```

### Changes
##### `docker-compose.yml`
- *ngrams* are mounted from `\home\<user>\ngrams`.
- Mapping for `cors` container to port 8081

##### `nginx/Dockerfile`
- NGINX logs are piped to `stdout`

##### `nginx/nginx.conf`

| conf                          | new value                        |
| ----------------------------- | -------------------------------- |
| `server`                      | `languagetool:8010;`             |
| `listen`                      | `8081`                           |
| `proxy_pass`                  | `http://language-tools/;`        |
| `upstream`                    | `language-tools`                 |
| `proxy_hide_header directive` | `'Access-Control-Allow-Origin';` |

### Credits
All credits to [@Erikvl87](https://github.com/Erikvl87) for the [docker-languagetool](https://github.com/Erikvl87/docker-languagetool) image and to [@maximillianfx](https://github.com/maximillianfx) for the [docker-nginx-cors](https://github.com/maximillianfx/docker-nginx-cors) image.

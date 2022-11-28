### nginx跨域配置

```
           set $cors_origin "";
           if ($http_origin ~ "https://(.*).exp.com") {
              set $cors_origin $http_origin;
           }
           if ($http_origin ~ "http://192.168.8.128:9999") {
              set $cors_origin $http_origin;
           }
           if ($http_origin ~ "http://127.0.0.1:8088") {
              set $cors_origin $http_origin;
           }
           if ($http_origin ~ "http://localhost:8088") {
              set $cors_origin $http_origin;
           }
           add_header Access-Control-Allow-Origin $cors_origin;
           add_header Access-Control-Allow-Credentials true;
           add_header Access-Control-Allow-Methods GET,POST;
```


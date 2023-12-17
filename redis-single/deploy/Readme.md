# k8s 部署单机 Redis



- [Redis 单机部署](https://blog.csdn.net/ss810540895/article/details/129259834?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522170281116016800197050129%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=170281116016800197050129&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-23-129259834-null-null.142^v96^pc_search_result_base6&utm_term=k8s%20%E9%83%A8%E7%BD%B2redis&spm=1018.2226.3001.4187)




如何修改 redis 连接密码？

1. 修改 redis.conf 文件，将 requirepass 改为你的密码。


```yaml
  redis.conf: |-
    dir /srv
    port 6379
    bind 0.0.0.0
    appendonly yes
    daemonize no
    #protected-mode no
    requirepass 123456
    pidfile /srv/redis-6379.pid
```

2. 重启 redis 的 pod。

```bash
kubectl -n my-namespace scale deploy my-deploy --replicas=0

kubectl -n my-namespace scale deploy my-deploy --replicas=1
```

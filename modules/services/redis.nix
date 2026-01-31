{ ... }:

{
  services.redis.servers.main = {
    enable = true;
    port = 6379;
  };

  services.prometheus.exporters.redis = {
    enable = true;
    port = 9121;
    redisAddress = "redis://127.0.0.1:6379";
  };
}

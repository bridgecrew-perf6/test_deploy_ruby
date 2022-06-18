# Need to run "heroku labs:enable user-env-compile -a MY_APP" first to get access to the env variables at compile time
# See http://stackoverflow.com/questions/16432825/heroku-precompile-assets-failed-on-rail-4-app
#
# From https://devcenter.heroku.com/articles/rediscloud#using-redis-from-java
uri = URI.parse(URI.encode(ENV['REDISCLOUD_URL'].to_s))
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# Configuring sidekiq's redis URL here works universally as opposed to doing it in unicorn.rb, which is not picked up when sidekiq is used
# outside unicorn, e.g. from the admin UI or from rails console
# The following is adopted from https://coderwall.com/p/fprnhg

# See https://github.com/mperham/sidekiq/wiki/Using-Redis
redis_namespace = "#{Rails.application.class.parent}_demo-#{Rails.env}"
Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], namespace: redis_namespace }
end
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], namespace: redis_namespace }
end

Peek::Railtie.routes.draw do
  get "/redis_expire" => 'redis_expires#expire', as: :redis_expire
end

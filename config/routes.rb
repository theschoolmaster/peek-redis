Peek::Railtie.routes.draw do
  get "/redis_expire" => 'expires#redis_expire', as: :redis_expire
end

Rails.application.routes.draw do
  root to: 'main#index'
  get '/ai_integration', to: 'ai_integration#index'
  post '/ai_integration/integrate', to: 'ai_integration#integrate'
  resources :publication_listings do
    resources :works
  end
end

Rails.application.routes.draw do
  root to: 'main#index'
  get '/ai_integration', to: 'ai_integration#index'
  post '/ai_integration/osp_integrate', to: 'ai_integration#osp_integrate'
  post '/ai_integration/lionpath_integrate', to: 'ai_integration#lionpath_integrate'
  post '/ai_integration/pure_integrate', to: 'ai_integration#pure_integrate'
  resources :publication_listings do
    resources :works
  end
end

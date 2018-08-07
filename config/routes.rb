Rails.application.routes.draw do
  root to: 'main#index'
  resources :publication_listings do
    resources :works
  end
end

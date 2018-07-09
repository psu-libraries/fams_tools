Rails.application.routes.draw do
  resources :publication_listings do
    resources :works
  end
end

Rails.application.routes.draw do
  resources :publication_listings do
    resources :works
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :converter, to: 'converter#index', as: :converter_index
  post :converter, to: 'converter#citation_parse', as: :converter_citation_parse
end

Rails.application.routes.draw do
  get 'works/new'

  get 'works/create'

  get 'works/update'

  get 'works/edit'

  get 'works/destroy'

  get 'works/index'

  get 'works/show'

  get 'publication_listings/new'

  get 'publication_listings/create'

  get 'publication_listings/update'

  get 'publication_listings/edit'

  get 'publication_listings/destroy'

  get 'publication_listings/index'

  get 'publication_listings/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :converter, to: 'converter#index', as: :converter_index
  post :converter, to: 'converter#citation_parse', as: :converter_citation_parse
end

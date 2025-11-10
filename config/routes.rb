require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root to: 'main#index'
  post '/main/update_ai_user_data', to: 'main#update_ai_user_data'
  get '/ai_integration', to: 'ai_integration#index'
  post '/ai_integration/render_integrator', to: 'ai_integration#render_integrator'
  post '/ai_integration/osp_integrate', to: 'ai_integration#osp_integrate'
  post '/ai_integration/lionpath_integrate', to: 'ai_integration#lionpath_integrate'
  post '/ai_integration/yearly_integrate', to: 'ai_integration#yearly_integrate'
  post '/ai_integration/pub_integrate', to: 'ai_integration#pub_integrate'
  post '/ai_integration/ldap_integrate', to: 'ai_integration#ldap_integrate'
  post '/ai_integration/delete_records', to: 'ai_integration#delete_records'
  post '/ai_integration/com_effort_integrate', to: 'ai_integration#com_effort_integrate'
  post '/ai_integration/com_quality_integrate', to: 'ai_integration#com_quality_integrate'
  post '/ai_integration/create_users_integrate', to: 'ai_integration#create_users_integrate'
  get '/ai_backups_listing', to: 'ai_backups_listing#index'
  get '/ai_backups_listing/download', to: 'ai_backups_listing#download'
  get '/post_prints', to: 'post_prints#index'
  post '/post_prints', to: 'post_prints#analyze'
  resources :publication_listings do
    resources :works
    get '/destroy', to: 'publication_listings#destroy'
    post '/update', to: 'publication_listings#update'
  end
  get 'ldap_check', to: 'ldap_check#index'
  post 'ldap_check', to: 'ldap_check#create'
end

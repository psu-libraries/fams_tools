Rails.application.routes.draw do
  root to: 'main#index'
  post '/main/update_ai_user_data', to: 'main#update_ai_user_data'
  get '/ai_integration', to: 'ai_integration#index'
  post '/ai_integration/render_integrator', to: 'ai_integration#render_integrator'
  post '/ai_integration/osp_integrate', to: 'ai_integration#osp_integrate'
  post '/ai_integration/lionpath_integrate', to: 'ai_integration#lionpath_integrate'
  post '/ai_integration/gpa_integrate', to: 'ai_integration#gpa_integrate'
  post '/ai_integration/pub_integrate', to: 'ai_integration#pub_integrate'
  post '/ai_integration/ldap_integrate', to: 'ai_integration#ldap_integrate'
  post '/ai_integration/cv_pub_integrate', to: 'ai_integration#cv_pub_integrate'
  post '/ai_integration/cv_presentation_integrate', to: 'ai_integration#cv_presentation_integrate'
  get '/ai_backups_listing', to: 'ai_backups_listing#index'
  get '/ai_backups_listing/download', to: 'ai_backups_listing#download'
  resources :publication_listings do
    resources :works
    get '/destroy', to: 'publication_listings#destroy'
  end
end

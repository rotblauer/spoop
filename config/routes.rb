Rails.application.routes.draw do

  get 'admin/humans'
  get 'admin/donations'
  get 'admin/logs'
  get 'admin/donor-insights' => 'admin#donor_insights', as: 'admin_donor_insights'
  get 'admin/meta-spoop', as: 'meta_spoop'

  root 'index#home'
  get 'terms-and-conditions' => 'index#terms_and_conditions'
  get 'support' => 'index#support'

  get 'ob_logs_by_donor_daily' => 'admin#ob_logs_by_donor_daily'

  devise_for :users, :controllers => { registrations: 'registrations' }
  
  resources :users do 

    resources :open_biome_logs do 
      collection do 
        get 'import' => 'open_biome_logs#import_setup'
        post 'import'
      end
    end

    resources :donor_logs do 
      member do 
        patch 'toggle_private'
      end
    end
    
    member do 
      get 'create-api-key' => 'users#create_api_key'  # prefix: create_api_key_user @ users/:id/create_api_key users#create_api_key
      get 'destroy-api-key'  => 'users#destroy_api_key' # prefix: destroy_api_key_user @ users/:id/destroy_api_key users#destroy_api_key
      get 'begin'
      get 'api-info' => 'users#api_info'
    end
  end

  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      resources :open_biome_logs, except: [:new, :edit]
      resources :donor_logs, except: [:new, :edit]
      get 'donor_logs_heatmap' => 'donor_logs#heatmap'

      get 'donor_logs_statistics' => 'donor_logs#statistics'
      get 'donor_logs_unixify' => 'donor_logs#unixify'
      get 'donor_logs_dayhour' => 'donor_logs#dayhour'
    end
  end

  get 'i-wish' => 'non_donors#new', as: 'new_non_donor'
  resources :non_donors, except: [:new]



  ############################################################################################
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

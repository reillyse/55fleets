require 'sidekiq/web'

require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root "home#welcome"

  get "home/setup" => "home#setup" , :as => :setup

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
  #   namespace :admin dos
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  authenticate :user, lambda { |u| u.email == "reillyse@gmail.com" || u.email == "sean@letsgodo.it" } do
    mount Sidekiq::Web => '/sidekiq'

  end

  get "machine/:id" , :to => "machines#show"
  get "fleet/:id", :to => "fleets#fleet_direct"

  resources :apps do
    resources :fleet_configs
    resources :fleets
    resources :env_configs
    resources :machines do
      put "log", :to => "machines#turn_on_logging"
    end
    resources :certs

    resources :pods do
      post "scale", :to  => "pods#scale", :as => :scale
    end
    post "fleet_configs/:id/launch", :to => "fleet_configs#launch", :as => :launch_fleet_config
    post "fleet_configs/:fleet_id/launch_from_fleet", :to => "fleet_configs#launch_from_fleet", :as => :revert_to_fleet
    resources :load_balancers do
      put "add_certificate/:cert_id", :to => "load_balancers#add_certificate", :as => "add_certificate"
      get "available_certificates", :to => "load_balancers#list_certificates", :as => "list_certificates"
    end

  end

  resources :repos


  get "fleet_configs/add_new_pod/", :to => "fleet_configs#add_new_pod_form", :as => :fleet_config_add_new_pod


  get "ping" => "application#keep_alive"

  get "apps/:app_id/fleets/log_entries/:machine_id/next_log/:last_log/timestamp" => "log_entries#get_next_log", :as => :next_log, :last_log => /.*/

  post "webhooks/push/:secret_key" => "webhooks#push", :as => :webhook


end
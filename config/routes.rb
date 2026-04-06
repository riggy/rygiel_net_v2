Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/page_views", to: "page_views#create"

  resources :conversations, only: [ :new, :create, :show ] do
    resources :messages, only: [ :create ], module: :conversations
  end

  root "pages#home"

  get "/cv", to: "curriculum_vitae#show", as: :cv
  get "/cv/print", to: "curriculum_vitae#print", as: :cv_print

  get "/blog", to: "blog#index", as: :blog
  get "/blog/:id", to: "blog#show", as: :blog_post

  namespace :admin do
    root to: "posts#index"
    resources :posts
    resources :projects do
      collection do
        patch :sort
      end
    end
    resources :now_entries
    resources :uploads, only: [ :create ]
    resources :site_configs, only: [ :index, :edit, :update ]
    resource :analytics, only: :show do
      post :flag_visitor
      delete :unflag_visitor
    end
    resources :whitelisted_ips, only: :create
    resource :curriculum_vitae, only: %i[edit update], controller: "curriculum_vitae"
    get :emojis, to: "emojis#index"
  end
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/page_views", to: "page_views#create"

  resources :conversations, only: [ :new, :create, :show ] do
    resources :messages, only: [ :create ], module: :conversations
  end

  root "pages#home"

  get "/blog", to: "blog#index", as: :blog
  get "/blog/:id", to: "blog#show", as: :blog_post

  namespace :admin do
    root to: "posts#index"
    resources :posts
    resources :projects
    resources :now_entries
    resources :site_configs, only: [ :index, :edit, :update ]
    resource :analytics, only: :show do
      post :flag_visitor
    end
    get :emojis, to: "emojis#index"
  end
end

Rails.application.routes.draw do
  mount Trackguard::Engine, at: "/trackguard", as: :trackguard

  get "up" => "rails/health#show", as: :rails_health_check

  get "/go/:slug", to: "referral_links#show", as: :referral_link

  resources :conversations, only: [ :new, :create, :show ] do
    resources :messages, only: [ :create ], module: :conversations
  end

  root "pages#home"

  get "/cv", to: "curriculum_vitae#show", as: :cv
  get "/cv/print", to: "curriculum_vitae#print", as: :cv_print

  get "/blog", to: "blog#index", as: :blog
  get "/blog/:id", to: "blog#show", as: :blog_post

  namespace :admin do
    root to: "dashboard#index"
    get :dashboard, to: "dashboard#index"
    resources :posts
    resources :projects do
      collection do
        patch :sort
      end
    end
    resources :now_entries
    resources :uploads, only: [ :create ]
    resources :site_configs, only: [ :index, :edit, :update ]
    resources :blocked_user_agents, only: %i[index create]
    resources :referral_links
    resource :curriculum_vitae, only: %i[edit update], controller: "curriculum_vitae"
    get :emojis, to: "emojis#index"
  end
end

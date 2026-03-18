Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "/blog", to: "blog#index", as: :blog
  get "/blog/:id", to: "blog#show", as: :blog_post

  namespace :admin do
    root to: "posts#index"
    resources :posts
    resources :projects
    resources :now_entries
    resources :site_configs, only: [:index, :edit, :update]
  end
end
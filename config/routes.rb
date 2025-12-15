Rails.application.routes.draw do
  devise_for :users
  resources :options
  resources :fields
  resources :forms do
    post :regenerate_link, on: :member
    resources :submissions, only: [:index, :new, :create, :show]
  end
  # Public short link to fill a form without authentication (via token)
  get "f/:token", to: "submissions#new", as: :fill_form
  namespace :admin do
    resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines conditional roots: unauthenticated -> login, authenticated -> forms list
  devise_scope :user do
    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  authenticated :user do
    root to: "forms#index", as: :authenticated_root
  end
end

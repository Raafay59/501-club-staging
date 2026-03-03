Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  get "/auth/:provider/callback", to: "sessions#create"
  post "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy", as: :logout
  get "/unauthorized", to: "sessions#unauthorized", as: :unauthorized

  resources :users, only: [ :index, :create, :update, :destroy ]

  resources :ideathons, param: :year do
    post :import, on: :collection
    member do
      get :delete
    end
  end

  resources :sponsors_partners do
    post :import, on: :collection
    member do
      get :delete
    end
  end

  resources :mentors_judges do
    post :import, on: :collection
    member do
      get :delete
    end
  end

  resources :faqs do
    post :import, on: :collection
    member do
      get :delete
    end
  end

  resources :rules do
    post :import, on: :collection
    member do
      get :delete
    end
  end

  root "ideathons#index"
end

Rails.application.routes.draw do
     root 'ideathon#index'

     devise_for :admins, controllers: { sessions: "admins/sessions", omniauth_callbacks: "admins/omniauth_callbacks" }
     devise_scope :admin do
          get "admins/sign_in", to: "admins/sessions#new", as: :new_admin_session
          delete "admins/sign_out", to: "admins/sessions#destroy", as: :destroy_admin_session
     end

     resources :manager, only: [ :index, :destroy ], controller: 'manager' do
          collection do
               get :export_participants
               get :export_teams
               get :view_pdf
          end
     end

     resources :ideathon_events, only: [ :new, :create, :edit, :update, :destroy ]

     resources :registered_attendees do
          collection do
               get :teams_for_year
               get :success
          end
     end

     scope path: "dashboard" do
          resources :users, only: [ :index, :create, :update, :destroy ]
          resources :activity_logs, only: [ :index ]

          resources :ideathons, param: :year do
               post :import, on: :collection
               member do
                    get :delete
                    get :overview
               end
          end

          resources :sponsors_partners do
               post :import, on: :collection
               get :export, on: :collection
               member do
                    get :delete
               end
          end

          resources :mentors_judges do
               post :import, on: :collection
               get :export, on: :collection
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
     end

     # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
     # Can be used by load balancers and uptime monitors to verify that the app is live.
     get "up" => "rails/health#show", as: :rails_health_check
end

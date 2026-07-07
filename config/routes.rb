Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :charts, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :grids, only: [ :show ]
    resources :tiles, only: [ :edit, :update ] do
      get :drill, on: :member
    end
  end

  root "charts#index"
end

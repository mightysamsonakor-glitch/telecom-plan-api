Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :options, only: :index
  resources :contract_terms, only: :index
  resources :plans, only: [ :show, :create ] do
    member { post :activate }
  end
end

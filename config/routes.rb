Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :movies
  get "series", to: "series#create", as: :series
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

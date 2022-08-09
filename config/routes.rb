Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  
  #resources :upload

  root "upload#index"
 
  post 'upload', to: "upload#create"

  #post 'upload/new', to: "upload#download_result"

  get 'upload/download_result', to: "upload#download_result"
end

Rails.application.routes.draw do
  #resources :upload

  root "upload#index"
 
  post 'upload', to: "upload#create"

  get 'upload/download_result', to: "upload#download_result"
end

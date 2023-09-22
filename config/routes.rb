Rails.application.routes.draw do
  resources :folders do
    member do
      delete 'remove_document/:document_id', to: 'folders#remove_document', as: 'remove_document'
    end
    resources :folders, only: [:new], shallow: true
  end
  post 'folders/:id/upload', to: 'folders#upload', as: 'upload_folder'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "folders#index"
end

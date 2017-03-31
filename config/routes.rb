Rails.application.routes.draw do

  devise_for :users, controllers: {
     sessions: 'users/sessions'
   }

  root 'places#index'

  resources :places, only: [:create, :index, :new] do
  	resources :events, shallow: true do
  		member do
  			post 'join'
        delete 'leave'
  		end
  		resources :posts, shallow: true, only:[:create]
  	end
  end

  resources :users, only: [:show]
  as :user do
    get 'users', :to => 'users#show', :as => :user_root # Rails 3
  end

end

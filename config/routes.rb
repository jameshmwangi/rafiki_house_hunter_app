Rails.application.routes.draw do
  # Development-only tools
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'

    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'
  end

  # Auth
  devise_for :users, controllers: { registrations: 'users/registrations' }

  # Admin — rails_admin (authenticated, admin-only)
  authenticate :user, ->(u) { u.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  # Root
  root 'pages#home'

  # Listings (public)
  resources :listings, only: [:index, :show] do
    resources :property_comments, only: [:index, :create, :destroy], path: 'comments'
    resources :viewing_appointments, only: [:new, :create], path: 'appointments'
  end

  # Locations (public)
  resources :locations, only: [:index, :show]

  # Favourites
  resources :favourites, only: [:index, :create, :destroy]

  # Agent Reviews
  resources :agent_reviews, only: [:new, :create, :edit, :update, :destroy]

  # Dashboard (agents / landlords)
  get 'dashboard', to: 'dashboard#index', as: :dashboard
  namespace :dashboard do
    resources :listings, except: [:show] do
      member do
        patch :publish
        patch :hide
      end
      resources :property_images, only: [:create, :destroy], path: 'images'
    end
    resources :viewing_appointments, only: [:index, :update], path: 'appointments', as: :appointments
  end

  # Account
  resource :account, only: [:show, :edit, :update], controller: 'accounts'

  # Agent Public Profile
  get 'agents/:id', to: 'agents#show', as: :agent_profile

  # Payment Attempts
  resources :payment_attempts, only: [:new, :create]

  # Error pages
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end

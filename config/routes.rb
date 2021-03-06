Rails.application.routes.draw do

  root 'static_pages#home'
  get 'about', to: 'static_pages#about'
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  get 'help', to: 'static_pages#help'
  get 'contact', to: 'static_pages#contact'

  get 'signup(/:invitation_token)', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :tracks, only: [:index, :show]
  resources :circuits, only: [:index, :show]
  resources :athletes do
    resource :profile
    get 'career_medals', on: :collection
  end
  resources :seasons, only: [:index, :show]

  resources :timesheets do
    get 'copy', on: :member

    resources :entries, shallow: true do
      collection { post :sort }
      resources :runs, shallow: true, except: :index
    end
    resources :points, only: [:index, :create]
  end

  resources :invitations, only: [:create]
  resources :points

  resources :notifications, only: [:index] do
    collection do
      post :mark_as_read
    end
  end

  get 'search', to: 'search#index'
  get '/rankings/', to: 'seasons#rankings', as: 'rankings'

  namespace :admin do
    resources :tracks
    resources :users
    resources :circuits
    resources :points
    resources :runs, only: :index
    resources :invitations
    resources :articles, only: [:index, :destroy]
    resources :timesheets
    get 'import', to: 'timesheet_imports#new', as: 'timesheet_import'
    post 'import', to: 'timesheet_imports#create'
  end

  namespace :api do # , defaults: { format: :json }
    namespace :v1 do
      resources :athletes, only: [:index, :show]
      resources :tracks, only: [:index, :show]
      resources :circuits, only: [:index, :show]
      resources :timesheets, only: [:index, :show] do
        resource :graph, only: [:create] do
          member do
            get 'by_run'
          end
        end
      end
      resources :entries
      # resources :users
      resources :seasons do
        get '/athletes/:athlete_id', to: 'seasons#athletes', on: :member
        get 'men', on: :member
        get 'women', on: :member
      end
      get '/rankings/:season_name', to: 'seasons#rankings'
    end
  end

  get '/become/:id', to: 'admin#become'

  require 'sidekiq/web'
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new

  # match '/about', to: 'static_pages#about', via: 'get'
  # match '/signup', to: 'users#new', via: 'get'
  # match '/signin', to: 'sessions#new', via: 'get'
  # match '/signout', to: 'sessions#destroy', via: 'delete'
  # match 'timesheets/:timesheet_id/startlist', to: 'entries#index', via: 'get'
end

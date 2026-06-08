Rails.application.routes.draw do
  root 'static_pages#top'
  get  '/signup', to: 'users#new'

  # ログイン
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    collection do
      get 'edit_all_basic_info'
      patch 'update_all_basic_info'
      post 'import'
      get 'working'
    end
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
    end
    resources :attendances, only: :update
  end

  resources :work_bases, except: %i[show]

  resources :overtime_requests, only: %i[new create] do
    collection do
      get :received
      patch :review
    end
  end
  resources :attendance_change_requests, only: %i[create]
end

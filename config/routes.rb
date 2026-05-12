Rails.application.routes.draw do
  get "home/index"
  resource :session
  # NOTE: `bin/rails generate authentication` によって自動生成されたパスワードリセット機能のルート。
  # ADR 001 の方針（管理者集中管理型認証）により、ユーザー自身によるリセット機能は本章では実装しない。
  # 将来の章で管理者によるリセット機能を実装する際に有効化すること。
  # resources :passwords, param: :token

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end

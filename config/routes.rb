Rails.application.routes.draw do
  root "welcome#index"
  get "welcome/index", to: "welcome#index", as: "welcome"

  get "/users/:id", to: "users#show", as: "user"

  get "/logout", to: "sessions#logout", as: "logout"
  get "/auth/google_oauth2/callback", to: "sessions#omniauth"
end

Rails.application.routes.draw do
  root "welcome#index"
  get "welcome/index", to: "welcome#index", as: "welcome"

  get "/users/:id", to: "users#show", as: "user"

  get "/logout", to: "sessions#logout", as: "logout"
  get "/auth/google_oauth2/callback", to: "sessions#omniauth"

  post "attendances/mark", to: "attendances#mark", as: "mark"

  #  Route to allow users to download the attendance report as a CSV file
  get "attendances/export_csv", to: "attendances#export_csv", as: "export_csv"
end

Rails.application.routes.draw do
  get "courses/index"
  get "courses/new"
  get "courses/create"
  get "courses/edit"
  get "courses/update"
  get "courses/destroy"
  root "welcome#index"
  get "welcome/index", to: "welcome#index", as: "welcome"

  get "/users/:id", to: "users#show", as: "user"
  get "showTA/:id", to: "users#showTA", as: "ta"
  get "showAdmin/:id", to: "users#showAdmin", as: "admin"
  get "users/showAdmin/:id", to: "users#showAdmin", as: "users_showAdmin"
  get "/logout", to: "sessions#logout", as: "logout"
  get "/auth/google_oauth2/callback", to: "sessions#omniauth"
  get "admin_uploads/new", to: "admin_uploads#new", as: "new_admin_upload"
  post "admin_uploads/create_admin_emails", to: "admin_uploads#create_admin_emails", as: "admin_upload"
  post "admin_uploads/create_ta_emails", to: "admin_uploads#create_ta_emails", as: "ta_upload"
  post "attendances/mark", to: "attendances#mark", as: "mark"
  get "upload_email", to: "admin_uploads#upload_email", as: "upload_email"
  post "upload_emails", to: "admin_uploads#upload_emails", as: "upload_emails"

  #  Route to allow users to download the attendance report as a CSV file
  # get "attendances/download_student_attendance", to: "attendances#download_student_attendance", as: "download_student_attendance"
  # get "attendances/download_ta_attendance", to: "attendances#download_ta_attendance", as: "download_ta_attendance"
  # get "attendances/download_student_attendance_count", to: "attendances#download_student_attendance_count", as: "download_student_attendance_count"
  # get "attendances/download_ta_attendance_count", to: "attendances#download_ta_attendance_count", as: "download_ta_attendance_count"

  get "attendances/download", to: "attendances#attendance", defaults: { format: "csv" }, as: "download_attendance"
  get "attendances", to: "attendances#attendance", as: "attendance"

  # , only: [ :index ]
  resources :courses
  resources :attendances
end

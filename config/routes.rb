Rails.application.routes.draw do
  root "welcome#index"
  get "welcome/index", to: "welcome#index", as: "welcome"

  get "/users/:id", to: "users#show", as: "user"
  get "showTA/:id", to: "users#showTA", as: "ta"
  get "showAdmin/:id", to: "users#showAdmin", as: "admin"

  get "/logout", to: "sessions#logout", as: "logout"
  get "/auth/google_oauth2/callback", to: "sessions#omniauth"

  post "attendances/mark", to: "attendances#mark", as: "mark"

  #  Route to allow users to download the attendance report as a CSV file
  get "attendances/download_student_attendance", to: "attendances#download_student_attendance", as: "download_student_attendance"
  get "attendances/download_ta_attendance", to: "attendances#download_ta_attendance", as: "download_ta_attendance"
  get "attendances/download_student_attendance_test", to: "attendances#download_student_attendance_test", as: "download_student_attendance_test"
  get "attendances/download_ta_attendance_test", to: "attendances#download_ta_attendance_test", as: "download_ta_attendance_test"
  get "attendances/attendance", to: "attendances#attendance", as: "attendance"
end

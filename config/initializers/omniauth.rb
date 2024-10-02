Rails.application.config.middleware.use OmniAuth::Builder do
    # Retrieve the Google credentials from Rails credentials
    google_credentials = Rails.application.credentials.google

    # Configure the Google OAuth provider with the client_id and client_secret
    if google_credentials && google_credentials[:client_id] && google_credentials[:client_secret]
        provider :google_oauth2, google_credentials[:client_id], google_credentials[:client_secret], {
          scope: "email, profile",
          prompt: "select_account",
          image_aspect_ratio: "square",
          image_size: 50
        }
    else
        Rails.logger.warn "Google OAuth2 credentials are missing or incomplete. Skipping configuration."
    end
end

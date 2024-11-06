# config/initializers/omniauth.rb

# Global error handler for OmniAuth failures
OmniAuth.config.on_failure = Proc.new do |env|
    # Fetch the error from the environment
    error = env['omniauth.error']
  
    # Use the URL helpers to generate the correct path
    welcome_url = Rails.application.routes.url_helpers.welcome_path
  
    # Check if there was an error and it was specifically an 'access_denied'
    if error.is_a?(OAuth2::Error) && error.error == 'access_denied'
      # Log the 'access_denied' error
      Rails.logger.warn "OAuth access denied: #{error.inspect}"
  
      # Create a new response and redirect to the welcome_url with an alert message
      response = Rack::Response.new
      response.redirect(welcome_url + "?alert=You denied the login request.")
      response.finish
    else
      # Log other types of errors
      Rails.logger.error "OAuth authentication failed: #{error.inspect}"
  
      # Create a new response and redirect to the welcome_url with a generic error message
      response = Rack::Response.new
      response.redirect(welcome_url + "?alert=Something went wrong during authentication.")
      response.finish
    end
  end
  
  # OAuth2 Provider (Google OAuth2)
  Rails.application.config.middleware.use OmniAuth::Builder do
    google_credentials = Rails.application.credentials.google
  
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
  
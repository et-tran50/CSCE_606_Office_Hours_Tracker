# Office Hours Tracker

- [Deployed Application](https://office-hours-tracker-a63f1f6d64ad.herokuapp.com/)

- [Code Climate Report](https://codeclimate.com/github/et-tran50/CSCE_606_Office_Hours_Tracker)
  Note: This report captures the state at the end of Sprint 3 and will not be updated in real-time.

- [Team Working Agreement](documentation/Fall2024/Team_Working_Agreement.md)
  
# Goal

- The app will allow students to mark their attendance. TAs can clock their shifts in the web application and mark their attendance. Admin can view Excel reports for payroll and analytics. Users can switch between student and admin roles depending on their class.

## Project Set Up

### Prerequisites

**Ruby version**: Ensure you have Ruby version 2.7.0 or higher installed. You can check the version of the ruby installed using the command `ruby -v`. The application used the `ruby 3.3.4` version.

**Rails version**: This project requires Rails 6.0 or higher. You can verify the rails version using the command `rails -v`. The application uses the `Rails 7.2.1` version.


### Clone the repository

```bash
git clone https://github.com/et-tran50/CSCE_606_Office_Hours_Tracker.git
cd CSCE_606_Office_Hours_Tracker
```

### Install Dependencies

- Execute the below command to install all the required gems

```bash
bundle install 
```
### Database Setup
- Create database

```bash
rails db:create
```

- Execute the DB migration to create the users table in the local database using the below command

```bash
rails db:migrate
```

- Create seed data into database, use the below command to prepopulate the database with list of authorized users

```bash
rails db:seed
```

### Running Application

- Launch the rails application using the below command, the application will be hosted on http://localhost or http://127.0.0.0 with the default port as 3000

```bash
rails server
```

### Google OAuth Configuration
#### Step 1: Create a New Project in Google Developer Console

1. Go to the Google Developer Console: [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. Select or create a project for your application (e.g., `office-hours-tracker`).

#### Step 2: Set Up OAuth Consent Screen

1. In your project, navigate to **APIs & Services** > **OAuth consent screen**.
2. Set the **User Type** to:
   - **External** for any user, or
   - **Internal** for specific accounts.
3. Fill out the required information:
   - App name
   - User support email
   - Developer contact information
4. Click **Save and Continue**.

#### Step 3: Create OAuth 2.0 Client ID

1. In **Credentials**, click on **Create Credentials** and select **OAuth client ID**.
2. Choose **Web application** as the application type.
3. Provide a name for your OAuth client.
4. Under **Authorized redirect URIs**, add the following URIs:
   - `http://localhost:3000/auth/google_oauth2/callback`
   - `http://127.0.0.1:3000/auth/google_oauth2/callback`
5. Click **Create**.
6. Save the **Client ID** and **Client Secret** provided.

#### Step 4: Add Authorized Redirect URI for Heroku (For Production)

1. In **Credentials**, click **Edit** for the OAuth 2.0 Client ID you created.
2. Add your Heroku app's callback URL as an authorized redirect URI:
   - `https://your-app-name.herokuapp.com/auth/google_oauth2/callback`
3. Click **Save**.

#### Step 5: Add OAuth ID and Secret to Rails Credentials

1. Open your Rails credentials file by running the following command:
   ```bash
   EDITOR=nano rails credentials:edit
The credentials file will open in the editor.

Add your Google OAuth credentials to the file in the following format. Make sure to maintain the correct indentation and spacing as shown. There should be 2 spaces before client_id and client_secret, and a space after the colon:

```bash
   google:
     client_id: your_client_id
     client_secret: your_client_secret
```

Note: Replace your_client_id and your_client_secret with your own Google OAuth credentials. Do not include any quotes around the actual credentials.

After adding your credentials, save the changes and exit the editor.

Now, your Google OAuth credentials are securely stored in the Rails credentials file and your application will be able to use them for authentication. Make sure to keep your credentials safe and secret.

### Running Tests

**NOTE**: Google OAuth Configuration is required for the application to start up smoothly and run tests.

Execute the below commands to run rspec

```bash
bundle exec rspec
```

Execute below command to run cucumber scenarios

```bash
bundle exec cucumber
```
### Heroku Deployment

**Login to Heroku through CLI**
If you have not already done so, install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#install-the-heroku-cli).

**Login to Heroku**:

1. heroku login

2. Create a Procfile
    ```bash
    echo "web: bundle exec rails server -p $PORT" > Procfile
    ```

    This file tells Heroku what to do when the application is deployed. In this case: spin up a web process to host the application.

3. Create a Heroku App
    ```bash
    heroku create <app_name>
    ```

4. Verify that the git remote is set:
    ```bash
    git config --list --local | grep heroku
    ```
5. Make Master Key Available on Heroku
    ```bash
    heroku config:set RAILS_MASTER_KEY=`cat config/master.key`
    ```
    This enables Rails on Heroku to decrypt the credentials.yml.enc file, which contains the OAuth credentials (and any other secrets your app needs).

6. Provision a Database
    ```bash
    heroku addons:create heroku-postgresql:essential
    ```
    An essential-0 PostgreSQL database costs $5 a month, prorated to the minute.

7. Add PostgreSQL to Gemfile

    ```bash
    group :production do
        gem 'pg'
    end
    ```
    Run this so that your app won't try to install production gems (like postgres) locally:

    ```bash
    bundle config set --local without 'production' && bundle install
    ```
8. Add the Heroku App to Authorized redirect URIs on Google Cloud Console
    - Go to the [Google Developer Console](https://console.cloud.google.com/).
    - Click on Credentials in the left navigation panel
    - Click on your OAuth 2.0 Client ID for this project
    - Add your Heroku app's callback address as an authorized redirect URI e.g. https://your-apps-name.herokuapp.com/auth/google_oauth2/callback
    - Click "SAVE"

9. Deploy the App to Heroku
    ```bash
    git push heroku main
    ```

10. Migrate the Database
    ```bash
    heroku run rails db:migrate
    ```
11. Seed the Database
- Note: Becuase of the role classification in the app, there will be two seeding steps. Please refer to the seed.rb for more details.
    ```bash
    heroku run rails db:seed
    ```

12. Launch the application:
    ```bash
    heroku open
    ```

Your app is now successfully deployed to the production environment.

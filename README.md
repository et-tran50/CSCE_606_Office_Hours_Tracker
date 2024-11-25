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
    ```bash
    heroku run rails db:seed
    ```

12. Launch the application:
    ```bash
    heroku open
    ```

Your app is now successfully deployed to the production environment.

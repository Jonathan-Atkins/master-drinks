# Setup Instructions

Fork and clone the repository:

```bash
git clone git@github.com:<YOUR_GITHUB_USER>/master-drinks.git
cd drink-lab-api
```

## Run the App with Docker

Docker runs both the Rails application and PostgreSQL database in separate containers.

1. Build and start the containers:

    ```bash
    docker-compose up --build -d
    ```

2. Prepare the Docker database:

    ```bash
    docker-compose exec app bin/rails db:migrate
    ```

3. Run the test suite inside the Rails container:

    ```bash
    docker-compose exec app bundle exec rspec
    ```

## Run the App Without Docker

1. Install dependencies:

    ```bash
    bundle install
    ```

2. Create and prepare the database:

    ```bash
    bin/rails db:create
    bin/rails db:migrate
    ```

3. Run the test suite:

    ```bash
    bundle exec rspec
    ```

4. Start the Rails server:

    ```bash
    bin/rails server
    ```
## View the Server

Local server available at (regardless of setup option):

```txt
http://localhost:3000
```

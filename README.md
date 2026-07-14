# README

# Drink Lab API

## Objective

Drink Lab API will be a Full-Stack REST API for managing a personal drink menu.

The current version allows users/developers to create, read, update, delete, and sort drinks. The long-term goal is to support bartenders or cocktail learners who want to save drinks, organize recipes, track ingredients, and eventually receive drink recommendations through AI.

## Who Is This For?

This app is for:

* Cocktail enthusiats who want to explore new cocktail ingredients
* Bartenders building a personal drink menu
* Developers learning API design, testing, deployment, and DevOps workflows

## Current Features

* RESTful CRUD endpoints for drinks
* Drink validation
* Category validation using Rails enums
* Sorting drinks by name, category, date added, and date edited
* JSON error responses
* RSpec test coverage
* GitHub Actions CI pipeline
* Render deployment
* Neon PostgreSQL production database

## Planned Features

* User registration
* User authentication
* Users saving drinks to their profile
* Recipes table
* Ingredients table
* Many-to-many relationship between users and drinks
* Many-to-many relationship between users and recipes
* Many-to-many relationship between users and ingredients
* Many-to-many relationship between recipes and ingredients
* OpenAI-powered drink recommendations
* Frontend interface

---

# How to Use App

## Setup Instructions

Clone the repository:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd drink-lab-api
```

### Run the App with Docker

Docker runs both the Rails application and PostgreSQL database in separate containers.

Build and start the containers:

```bash
docker-compose up --build -d
```

Prepare the Docker database:

```bash
docker-compose exec app bin/rails db:migrate
```

Run the test suite inside the Rails container:

```bash
docker-compose exec app bundle exec rspec
```

The API will be available at:

```txt
http://localhost:3000
```

View the running containers:

```bash
docker ps
```

View application logs:

```bash
docker-compose logs app
```

Stop and remove the containers:

```bash
docker-compose down
```

The PostgreSQL data remains saved in the Docker volume after the containers are stopped.

To delete the containers and local Docker database data:

```bash
docker-compose down -v
```

> Warning: The `-v` option deletes the local Docker database volume.

### Run the App Without Docker

Install dependencies:

```bash
bundle install
```

Create and prepare the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Run the test suite:

```bash
bundle exec rspec
```

Start the Rails server:

```bash
bin/rails server
```

The local server runs at:

```txt
http://localhost:3000
```

Clone the repository:

```bash
git clone <https://master-drinks.onrender.com>
cd drink-lab-api
```

Install dependencies:

```bash
bundle install
```

Create and prepare the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Run the test suite:

```bash
bundle exec rspec
```

Start the Rails server:

```bash
bundle exec rails s
```

The local server runs at:

```txt
http://localhost:3000
```

## Backend or Frontend?

This project is currently backend-only.

Current backend:

```txt
Rails API
PostgreSQL
RSpec
Render
Neon
GitHub Actions
```

Frontend:

```txt
Planned, not yet implemented
```

## 30-Second Startup

```bash
bundle install
bin/rails db:create db:migrate
bundle exec rails s
```

Then test the API:

```bash
curl http://localhost:3000/api/v1/drinks
```

---

# Breakdown

## Backend First

The backend is being built first so the API contract, database structure, tests, and deployment workflow are stable before adding a frontend.

Current backend focus:

* Drink CRUD
* User model
* UserDrink join table
* Authentication planning
* API contract documentation
* Production deployment

## Frontend After Backend

The frontend will be built after the backend is stable.

The future frontend should allow a user to:

* View all saved drinks
* Create a new drink
* Edit a drink
* Delete a drink
* Save drinks to a personal profile
* View recipes
* View ingredients
* Ask for AI-powered drink recommendations

---

# Server

## Current Drink Endpoints

### Get All Drinks

```http
GET /api/v1/drinks
```

Returns all drinks.

Example response:

```json
[
  {
    "id": 1,
    "name": "Margarita",
    "category": "tequila",
    "alcoholic": true,
    "created_at": "2026-06-10T04:57:25.806Z",
    "updated_at": "2026-06-10T04:57:25.806Z"
  }
]
```

### Get One Drink

```http
GET /api/v1/drinks/:id
```

Returns one drink by ID.

### Create Drink

```http
POST /api/v1/drinks
```

Request body:

```json
{
  "name": "Margarita",
  "category": "tequila",
  "alcoholic": true
}
```

Example response:

```json
{
  "id": 1,
  "name": "Margarita",
  "category": "tequila",
  "alcoholic": true,
  "created_at": "2026-06-10T04:57:25.806Z",
  "updated_at": "2026-06-10T04:57:25.806Z"
}
```

### Update Drink

```http
PATCH /api/v1/drinks/:id
```

Request body:

```json
{
  "name": "Margarita Picante"
}
```

### Delete Drink

```http
DELETE /api/v1/drinks/:id
```

Successful response:

```txt
204 No Content
```

---

# User Registration

User registration is planned but not fully implemented yet.

Planned endpoint:

```http
POST /api/v1/users
```

The body of the post request will be a JSON payload:

```json
{
  "name": "John Doe",
  "username": "johndoe",
  "email": "someone@example.com",
  "password": "password",
  "password_confirmation": "password"
}
```

Example JSON response:

```json
{
  "data": {
    "type": "user",
    "id": "1",
    "attributes": {
      "name": "John Doe",
      "username": "johndoe",
      "email": "someone@example.com"
    }
  }
}
```

Future versions may include an API key or token-based authentication.

---

# Schema Diagram

Current and planned schema direction:

```txt
users
- id
- name
- username
- email
- password_digest
- created_at
- updated_at

drinks
- id
- name
- category
- alcoholic
- created_at
- updated_at

user_drinks
- id
- user_id
- drink_id
- favorite
- mastered
- notes
- created_at
- updated_at
```

Relationship:

```txt
User has many UserDrinks
User has many Drinks through UserDrinks

Drink has many UserDrinks
Drink has many Users through UserDrinks
```

Planned future schema:

```txt
recipes
- id
- drink_id
- instructions
- created_at
- updated_at

ingredients
- id
- name
- measurement_unit
- created_at
- updated_at

recipe_ingredients
- id
- recipe_id
- ingredient_id
- amount
- measurement_unit
- created_at
- updated_at

user_recipes
- id
- user_id
- recipe_id
- notes
- favorite
- created_at
- updated_at

user_ingredients
- id
- user_id
- ingredient_id
- created_at
- updated_at
```

Planned relationship:

```txt
Recipe has many Ingredients through RecipeIngredients
Ingredient has many Recipes through RecipeIngredients

User has many Recipes through UserRecipes
User has many Ingredients through UserIngredients
```

---

# Frontend

The frontend has not been implemented yet.

Planned user experience:

* As a user, I can register for an account.
* As a user, I can log in.
* As a user, I can view my saved drinks.
* As a user, I can save a drink to my profile.
* As a user, I can mark a drink as mastered.
* As a user, I can favorite a drink.
* As a user, I can view ingredients for a recipe.
* As a user, I can ask for a drink recommendation based on ingredients or taste preferences.

Example future flow:

```txt
User lands on homepage
User logs in
User clicks "My Drinks"
User sees saved drinks
User clicks "Add Drink"
User fills out drink form
User saves drink to profile
```

---

# DevOps and Deployment

This app uses GitHub Actions for CI.

Current CI checks:

* RSpec test suite
* RuboCop linting
* Brakeman security scanning
* Bundler audit

Production deployment:

```txt
App hosting: Render
Production database: Neon PostgreSQL
```

Local database and production database are separate.

```txt
Local development database: PostgreSQL running in Docker
Production database: Neon PostgreSQL
```

---

# Citations / Tools Used

Tools and technologies used in this app:

* Ruby
* Ruby on Rails API
* PostgreSQL
* RSpec
* SimpleCov
* RuboCop
* Brakeman
* Bundler Audit
* GitHub Actions
* Render
* Neon PostgreSQL
* Postman
* OpenAI API, planned

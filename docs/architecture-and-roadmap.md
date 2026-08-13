# Architecture & Roadmap

This repo is backend-only. It's the Rails API that a separate React frontend
project consumes; no frontend code lives here.

**Current backend:**

* Rails API
* PostgreSQL
* RSpec
* Render
* GitHub Actions

## Resource Map

The backend is organized around the following resources. Full request/response
bodies for the resources that are already built live in
[docs/api-contract.md](api-contract.md); this doc tracks what exists at the
route level and what's still planned.

> **Auth assumption:** `my_recipes` and `my_drinks` are scoped to the
> currently authenticated user (via `user_recipes` / `user_drinks`), so they
> depend on auth landing first. Adjust below once auth is implemented if the
> approach changes.

### Users

| Method | Endpoint | Description |
|---|---|---|
| (!) GET | `/api/v1/users` | List all users |
| GET | `/api/v1/users/:id` | Get one user |
| POST | `/api/v1/users` | Create a user (registration) |
| PATCH/PUT | `/api/v1/users/:id` | Update a user |
| DELETE | `/api/v1/users/:id` | Delete a user |

See [docs/user-registration.md](user-registration.md) for the registration payload.

### Drinks

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/drinks` | List all drinks |
| GET | `/api/v1/drinks/:id` | Get one drink |
| POST | `/api/v1/drinks` | Create a drink |
| PATCH/PUT | `/api/v1/drinks/:id` | Update a drink |
| DELETE | `/api/v1/drinks/:id` | Delete a drink |

Fully documented in [docs/api-contract.md](api-contract.md).

### Recipes

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/recipes` | List all recipes |
| GET | `/api/v1/recipes/:id` | Get one recipe |
| POST | `/api/v1/recipes` | Create a recipe |
| PATCH/PUT | `/api/v1/recipes/:id` | Update a recipe |
| DELETE | `/api/v1/recipes/:id` | Delete a recipe |

A recipe belongs to a drink (`drink_id`) and holds `instructions`.

### Ingredients

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/ingredients` | List all ingredients |
| GET | `/api/v1/ingredients/:id` | Get one ingredient |
| POST | `/api/v1/ingredients` | Create an ingredient |
| PATCH/PUT | `/api/v1/ingredients/:id` | Update an ingredient |
| DELETE | `/api/v1/ingredients/:id` | Delete an ingredient |

### Recipe Ingredients

Join resource linking recipes to ingredients, with amount and measurement unit.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/recipes/:recipe_id/recipe_ingredients` | List ingredients for a recipe |
| GET | `/api/v1/recipe_ingredients/:id` | Get one recipe-ingredient entry |
| POST | `/api/v1/recipes/:recipe_id/recipe_ingredients` | Add an ingredient to a recipe |
| PATCH/PUT | `/api/v1/recipe_ingredients/:id` | Update amount/unit |
| DELETE | `/api/v1/recipe_ingredients/:id` | Remove an ingredient from a recipe |

### My Recipes

Join resource (`user_recipes`) scoped to the current user, with `notes` and `favorite`.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/my_recipes` | List the current user's saved recipes |
| GET | `/api/v1/my_recipes/:id` | Get one saved recipe entry |
| POST | `/api/v1/my_recipes` | Save a recipe to the current user's profile |
| PATCH/PUT | `/api/v1/my_recipes/:id` | Update notes / toggle favorite |
| DELETE | `/api/v1/my_recipes/:id` | Remove a recipe from the current user's profile |

### My Drinks

Join resource (`user_drinks`) scoped to the current user, with `favorite`,
`mastered`, and `notes`.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/my_drinks` | List the current user's saved drinks |
| GET | `/api/v1/my_drinks/:id` | Get one saved drink entry |
| POST | `/api/v1/my_drinks` | Save a drink to the current user's profile |
| PATCH/PUT | `/api/v1/my_drinks/:id` | Update notes / toggle favorite / mastered |
| DELETE | `/api/v1/my_drinks/:id` | Remove a drink from the current user's profile |

## Backend To-do list

The backend is being built first so the API contract, database structure, tests, and deployment workflow are stable before adding a frontend.

Current backend focus:

- [x] Drink CRUD
- [x] User CRUD
- [x] Recipe CRUD
- [ ] Ingredient CRUD
- [x] Recipe Ingredients (join)
- [x] My Recipes (join, user-scoped)
- [x] My Drinks (join, user-scoped)
- [ ] Dashboard endpoint
- [ ] Authentication - **Need to add to AppController**
- [/] API contract documentation
- [x] Production deployment
# Drink Lab API

The Rails backend for a cocktail recipe app. It serves a separate React frontend and handles drinks, recipes, ingredients, and (eventually) user profiles.

## Features

- Browse cocktail recipes
- Save your favorite drinks
- Create your own cocktail recipes
- Share recipes with the community
- Organize drinks and ingredients in one place

## Tech Stack

**Backend:** Ruby, Ruby on Rails 8.1.3, PostgreSQL, ActiveRecord, bcrypt authentication, rack-cors

**Testing & Quality:** RSpec, FactoryBot, SimpleCov, Brakeman, Bundler Audit

**DevOps & Deployment:** Docker, GitHub Actions, Bundler

## Quick Start

```bash
git clone git@github.com:<YOUR_GITHUB_USER>/master-drinks.git
cd drink-lab-api
bundle install
bin/rails db:create db:migrate
bundle exec rails s
```

Then test it:

```bash
curl http://localhost:3000/api/v1/login
```

For Docker-based setup, database resets, and running the test suite, see [docs/setup.md](docs/setup.md).

## Status

This repo is **backend-only**; the React frontend lives in a separate repo. For status updates on individual components of this project see the [docs/architecture-and-roadmap.md](docs/architecture-and-roadmap.md)

## Documentation

* [Setup (Docker & local)](docs/setup.md)
* [Architecture & Roadmap](docs/architecture.md)
* [API Contract](docs/api-contract.md)
* [DevOps & Deployment](docs/devops.md)
# Dev-ops and Deployment

## CI/CD Pipeline (GitHub Actions)

# DevOps and Deployment

## CI/CD Pipeline (GitHub Actions)

Defined in `.github/workflows/ci.yml`. Runs on every pull request and on
pushes to `main`, with three jobs running in parallel.

### `scan_ruby`

Static security scanning:

* [Brakeman](https://brakemanscanner.org/) checks the Rails codebase for common vulnerabilities (SQL injection, mass assignment, XSS, etc.).
* [`bundler-audit`](https://github.com/rubysec/bundler-audit) checks the Gemfile lock against the known CVE database for gems.
### `lint`

Runs RuboCop for style consistency, with caching keyed on `.ruby-version`, `.rubocop.yml`, `.rubocop_todo.yml`, and `Gemfile.lock` so unrelated pushes don't re-lint from a cold cache. The cache key is scoped per-branch except on the default branch, which always gets a fresh run.

### `test`

Runs the RSpec suite against a real Postgres service container (not SQLite/mocked):

* Installs `libpq-dev` and `libvips` (native deps for Postgres and image processing).
* Spins up a `postgres` service on `5432` with a health check so the job waits for the DB to be ready before running tests.
* Prepares the test database (`bin/rails db:prepare`) and runs `bundle exec rspec`.
* A Redis service block is present but commented out, ready to enable if/when the app adds a Redis dependency (background jobs, caching, Action Cable, etc.).
All three jobs use `ruby/setup-ruby` with `bundler-cache: true`, so `bundle install` is cached and skipped when the lockfile hasn't changed.

## Render Deployment

TBD
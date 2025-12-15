# Dynamic Forms (Rails 8)

Small Rails 8 app to configure simple forms and collect submissions (Google Forms–like).

## Stack
- Ruby 3.4, Rails 8.0, SQLite
- No auth; minimal server-rendered views

## Features
- Create forms with a title
- Add fields (text, number, select)
- For select fields, add options (label + value)
- Fill a form and save a submission
- View all submissions per form and inspect each submission

## Setup (PostgreSQL + Tailwind)

```bash
cd forms_app
bundle install
# Ensure PostgreSQL is running. On macOS (Homebrew):
brew services start postgresql@14

# Create/migrate/seed
bin/rails db:setup

# Start app (with Tailwind watcher in another terminal if desired)
bin/rails server -p 3000
# or for concurrent Tailwind watcher and Rails (requires foreman):
bin/dev
```

Visit http://localhost:3000

## Usage
- Forms list: create/edit forms, quick links to Fill and Submissions
- On a Form page, manage its Fields. For a select field, manage its Options.
- Fill a form via "Fill this form"; values are stored as responses.

## Notes
- PostgreSQL is now the default database (see `config/database.yml`).
- Numeric fields validate basic numeric input on submit.
- Deleting a form cascades to fields and submissions.

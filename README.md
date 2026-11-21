# Telecom Plan API

![CI](https://github.com/mightysamsonakor-glitch/telecom-plan-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-8.1-D30001?logo=rubyonrails&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.4-4479A1?logo=mysql&logoColor=white)

A REST API for **building your own mobile plan**. Customers pick how much data, how many call minutes and SMS they want, choose a contract length, and the API calculates the monthly price with the contract discount.

## Features

- Browse plan components (data, minutes, SMS) and their options, cheapest first
- Build a plan in one request; the customer, plan and items are saved in a **single transaction**
- Price calculation with contract discounts (1, 12 or 24 months)
- Plan lifecycle: `draft` → `active` → `cancelled`
- Consistent JSON errors: `400` missing params, `404` not found, `422` invalid data

## Data model

~~~
customers ──< plans >── contract_terms
                │
                └──< plan_items >── component_options >── components
                                                          (DATA, MINUTES, SMS)
~~~

Business rules are enforced **twice**, in the models and in MySQL:

| Rule | Model | Database |
|---|---|---|
| One option per component in a plan | uniqueness validation | unique index on `(plan_id, component_id)` |
| An option is either a fixed amount or unlimited | validations | `CHECK` constraint |
| Discount between 0 and 50% | numericality validation | `CHECK` constraint |
| Unique customer email (case-insensitive) | `normalizes` + uniqueness | unique index |

Money is stored as integer **cents** to avoid floating-point rounding errors.

## Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/options` | Components and their available options |
| `GET` | `/contract_terms` | Contract lengths and discounts |
| `POST` | `/plans` | Build a plan |
| `GET` | `/plans/:id` | Plan details and price |
| `POST` | `/plans/:id/activate` | Activate a draft plan |
| `GET` | `/up` | Health check |

### Example

~~~bash
curl -X POST http://localhost:3000/plans \
  -H "Content-Type: application/json" \
  -d '{
        "name": "Student Max",
        "contract_months": 12,
        "option_ids": [2, 7],
        "customer": { "full_name": "Ona Petraitytė", "email": "ona@example.com" }
      }'
~~~

Response (shortened):

~~~json
{
  "id": 1,
  "name": "Student Max",
  "status": "draft",
  "contract_months": 12,
  "discount_percent": 10,
  "items": [
    { "component": "DATA", "option": "20 GB", "monthly_price_cents": 699 },
    { "component": "MINUTES", "option": "unlimited min", "monthly_price_cents": 599 }
  ],
  "base_price_cents": 1298,
  "monthly_price_cents": 1168
}
~~~

## Run it locally

Requirements: Ruby 3.4, Docker.

~~~bash
docker compose up -d          # MySQL 8.4 and Redis
bundle install
bin/rails db:prepare db:seed  # creates tables and sample options
bin/rails server              # http://localhost:3000
~~~

## Tests

~~~bash
bin/rails test
~~~

Model tests cover pricing and validation rules; integration tests cover every endpoint, including error cases. GitHub Actions runs the tests, RuboCop and Brakeman security scanning on every push and pull request.

## Roadmap

- [ ] Cache the option list in Redis
- [ ] Authentication for customers
- [ ] Cancel plans and plan history

## Author

Built by [Mighty Samson Akor](https://github.com/mightysamsonakor-glitch), ICT student at VILNIUS TECH.

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_15_210000) do
  create_table "component_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.integer "amount"
    t.boolean "unlimited", default: false, null: false
    t.integer "monthly_price_cents", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_component_options_on_component_id"
    t.check_constraint "((`unlimited` = true) and (`amount` is null)) or ((`unlimited` = false) and (`amount` is not null) and (`amount` > 0))", name: "amount_or_unlimited"
  end

  create_table "components", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "unit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_components_on_code", unique: true
  end

  create_table "contract_terms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "months", null: false
    t.integer "discount_percent", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["months"], name: "index_contract_terms_on_months", unique: true
    t.check_constraint "`discount_percent` between 0 and 50", name: "discount_range"
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "plan_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "component_id", null: false
    t.bigint "component_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_plan_items_on_component_id"
    t.index ["component_option_id"], name: "index_plan_items_on_component_option_id"
    t.index ["plan_id", "component_id"], name: "index_plan_items_on_plan_id_and_component_id", unique: true
    t.index ["plan_id"], name: "index_plan_items_on_plan_id"
  end

  create_table "plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "contract_term_id", null: false
    t.string "name", null: false
    t.string "status", default: "draft", null: false
    t.datetime "activated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_term_id"], name: "index_plans_on_contract_term_id"
    t.index ["customer_id"], name: "index_plans_on_customer_id"
    t.index ["status"], name: "index_plans_on_status"
  end

  add_foreign_key "component_options", "components"
  add_foreign_key "plan_items", "component_options"
  add_foreign_key "plan_items", "components"
  add_foreign_key "plan_items", "plans"
  add_foreign_key "plans", "contract_terms"
  add_foreign_key "plans", "customers"
end

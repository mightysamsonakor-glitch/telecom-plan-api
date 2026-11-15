class CreateTelecomTables < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.timestamps
    end
    add_index :customers, :email, unique: true

    create_table :components do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :unit, null: false
      t.timestamps
    end
    add_index :components, :code, unique: true

    create_table :component_options do |t|
      t.references :component, null: false, foreign_key: true
      t.integer :amount
      t.boolean :unlimited, null: false, default: false
      t.integer :monthly_price_cents, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_check_constraint :component_options,
      "(unlimited = TRUE AND amount IS NULL) OR (unlimited = FALSE AND amount IS NOT NULL AND amount > 0)",
      name: "amount_or_unlimited"

    create_table :contract_terms do |t|
      t.integer :months, null: false
      t.integer :discount_percent, null: false, default: 0
      t.timestamps
    end
    add_index :contract_terms, :months, unique: true
    add_check_constraint :contract_terms, "discount_percent BETWEEN 0 AND 50", name: "discount_range"

    create_table :plans do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :contract_term, null: false, foreign_key: true
      t.string :name, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :activated_at
      t.timestamps
    end
    add_index :plans, :status

    create_table :plan_items do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.references :component_option, null: false, foreign_key: true
      t.timestamps
    end
    add_index :plan_items, [ :plan_id, :component_id ], unique: true
  end
end

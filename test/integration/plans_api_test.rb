require "test_helper"

class PlansApiTest < ActionDispatch::IntegrationTest
  setup do
    data = Component.create!(code: "DATA", name: "Mobile data", unit: "GB")
    minutes = Component.create!(code: "MINUTES", name: "Call minutes", unit: "min")
    @gb20 = data.component_options.create!(amount: 20, monthly_price_cents: 699)
    @gb5 = data.component_options.create!(amount: 5, monthly_price_cents: 399)
    @unlimited_min = minutes.component_options.create!(unlimited: true, monthly_price_cents: 599)
    ContractTerm.create!(months: 12, discount_percent: 10)
  end

  def create_plan(option_ids)
    post "/plans", as: :json, params: {
      name: "My plan", contract_months: 12, option_ids: option_ids,
      customer: { full_name: "Ona", email: "ona@example.com" }
    }
  end

  test "lists components with their options, cheapest first" do
    get "/options", as: :json

    assert_response :success
    data = response.parsed_body.find { |component| component["code"] == "DATA" }
    assert_equal [ "5 GB", "20 GB" ], data["options"].map { |option| option["label"] }
  end

  test "creates a plan and returns its discounted price" do
    create_plan([ @gb20.id, @unlimited_min.id ])

    assert_response :created
    body = response.parsed_body
    assert_equal "draft", body["status"]
    assert_equal 1298, body["base_price_cents"]
    assert_equal 1168, body["monthly_price_cents"]
    assert_equal 2, body["items"].size
  end

  test "rejects two options for the same component and saves nothing" do
    assert_no_difference [ "Plan.count", "Customer.count" ] do
      create_plan([ @gb20.id, @gb5.id ])
    end

    assert_response :unprocessable_content
  end

  test "returns 400 when option_ids are missing" do
    post "/plans", as: :json, params: { name: "x", contract_months: 12, customer: { full_name: "Ona", email: "ona@example.com" } }

    assert_response :bad_request
  end

  test "returns 404 for an unknown plan" do
    get "/plans/999999", as: :json

    assert_response :not_found
  end

  test "activates a plan" do
    create_plan([ @gb20.id ])
    plan_id = response.parsed_body["id"]

    post "/plans/#{plan_id}/activate", as: :json

    assert_response :success
    assert_equal "active", response.parsed_body["status"]
    assert_not_nil response.parsed_body["activated_at"]
  end
end

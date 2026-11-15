require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "stores email in lowercase and keeps it unique" do
    Customer.create!(full_name: "Ona", email: " Ona@Example.com ")

    assert_equal "ona@example.com", Customer.last.email
    assert_not Customer.new(full_name: "Copy", email: "ONA@example.com").valid?
  end
end

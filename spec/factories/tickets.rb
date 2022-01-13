# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    event
    available { Faker::Number.number(digits: 2) }
    price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end

  trait :with_reserved_and_paid_reservations do
    after(:create) do |ticket|
      create(:reservation, ticket: ticket, status: :reserved)
      create(:reservation, ticket: ticket, status: :paid)
    end
  end
end

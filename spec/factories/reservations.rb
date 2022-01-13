FactoryBot.define do
  factory :reservation do
    tickets_count { Faker::Number.between(from: 1, to: 4) }
    status { :reserved }
    cost { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    ticket
  end
end

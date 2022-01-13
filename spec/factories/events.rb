# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::FunnyName.four_word_name }
    time { Faker::Time.forward }

    trait :with_ticket do
      after(:create) do |event|
        create(:ticket, event: event)
      end
    end

    trait :with_even_tickets do
      after(:create) do |event|
        create(:ticket, event: event, validation_type: :even)
      end
    end

    trait :with_avoid_one_tickets do
      after(:create) do |event|
        create(:ticket, event: event, validation_type: :avoid_one)
      end
    end
  end
end

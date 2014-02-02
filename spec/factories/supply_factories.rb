FactoryGirl.define do
  factory :supply do
    trait :with_recurring_uses do
      after_create do |supply|
        FactoryGirl.create(:recurring_use, :supply => supply)
      end
    end
  end
end
FactoryBot.define do
  factory :comment, class: ForumComment do
    title      { 'Sample Forum Comment' }
    body       { 'Lorem...' }
  end
end

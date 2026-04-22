class Rule < ApplicationRecord
     include ActivityTrackable
     include AssignsIdeathonByYear

     belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :rules, touch: true

     validates :rule_text, presence: true
     validates :ideathon, presence: true
end

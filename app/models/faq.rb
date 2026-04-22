class Faq < ApplicationRecord
     include ActivityTrackable
     include AssignsIdeathonByYear

     belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :faqs, touch: true

     validates :question, presence: true
     validates :answer, presence: true
     validates :ideathon, presence: true
end

class IdeathonEvent < ApplicationRecord
     belongs_to :ideathon_year, class_name: "Ideathon", inverse_of: :ideathon_events
end

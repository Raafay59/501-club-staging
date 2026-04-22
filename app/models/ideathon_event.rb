class IdeathonEvent < ApplicationRecord
     belongs_to :ideathon_year

     validates :event_name, :event_date, :event_time, presence: true
end

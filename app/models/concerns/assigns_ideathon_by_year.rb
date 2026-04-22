# frozen_string_literal: true

# Virtual year accessor for records that belong_to :ideathon (Ideathon maps to ideathon_years).
module AssignsIdeathonByYear
     extend ActiveSupport::Concern

     def year
          ideathon&.year
     end

     def year=(value)
          if value.blank?
               self.ideathon = nil
               return
          end

          self.ideathon = Ideathon.find_by!(year: value.to_i)
     end
end

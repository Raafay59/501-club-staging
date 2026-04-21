# frozen_string_literal: true

class Ideathon < ApplicationRecord
     self.table_name = "ideathon_years"
     self.inheritance_column = nil

     include ActivityTrackable
     include IdeathonYearShared

     # Override default associations to use inverse_of pointing at :ideathon
     # (needed because IdeathonYearShared associations use inverse_of :ideathon_year)
     has_many :sponsors_partners, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
     has_many :mentors_judges, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
     has_many :faqs, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
     has_many :rules, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon

     def to_param
          year.to_s
     end
end

class Judge < ApplicationRecord
    has_one_attached :judge_photo

    validates :judge_name, presence: true
    validates :judge_title, presence: true
    validates :judge_bio, presence: true
    validates :ideathon, presence: true
end

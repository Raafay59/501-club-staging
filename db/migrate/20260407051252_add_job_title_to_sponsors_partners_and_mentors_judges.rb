class AddJobTitleToSponsorsPartnersAndMentorsJudges < ActiveRecord::Migration[8.0]
  def change
    add_column :sponsors_partners, :job_title, :string
    add_column :mentors_judges, :job_title, :string
  end
end

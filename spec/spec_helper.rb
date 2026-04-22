require "simplecov"
SimpleCov.start "rails" do
     minimum_coverage 90
     coverage_dir File.expand_path("../coverage", __dir__)

     # Exclude code that isn’t in use
     add_filter "app/jobs/application_job.rb"
     add_filter "app/mailers/application_mailer.rb"
     add_filter "app/controllers/admins/sessions_controller.rb"
end

RSpec.configure do |config|
     config.expect_with :rspec do |expectations|
          expectations.include_chain_clauses_in_custom_matcher_descriptions = true
     end

     config.mock_with :rspec do |mocks|
          mocks.verify_partial_doubles = true
     end

     config.shared_context_metadata_behavior = :apply_to_host_groups
     config.filter_run_when_matching :focus
     config.example_status_persistence_file_path = "spec/examples.txt"
     config.disable_monkey_patching!
     config.warnings = true
     config.default_formatter = "doc" if config.files_to_run.one?
     config.profile_examples = 10
     config.order = :random
     Kernel.srand config.seed
end

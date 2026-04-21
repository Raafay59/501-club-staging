web: bundle exec puma -C config/puma.rb
worker: bundle exec bin/jobs start
release: DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:migrate && bundle exec rails db:seed

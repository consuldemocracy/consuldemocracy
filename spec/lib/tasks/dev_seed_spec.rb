require 'rake'
require 'rails_helper'
Rake::Task.define_task(:environment)
Rake.application.rake_require('tasks/db')

describe 'rake db:dev_seed' do
  let :run_rake_task do
    Rake.application.invoke_task('db:dev_seed')
  end

  it 'seeds the database without errors' do
    expect { run_rake_task }.not_to raise_error
  end
end

require 'rails_helper'
require 'rake'

describe 'rake db:dev_seed' do
  before do
    Rake.application.rake_require('tasks/db')
    Rake::Task.define_task(:environment)
  end

  let :run_rake_task do
    Rake::Task['db:dev_seed'].reenable
    Rake.application.invoke_task('db:dev_seed')
  end

  it 'seeds the database without errors' do
    expect { run_rake_task }.not_to raise_error
  end
end
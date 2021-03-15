# Meant to loosely mimic Heroku's Scheduler API
namespace :scheduler do
  desc "All the tasks that need to run every 10 minutes"
  task every_10_minutes: []

  desc "All the tasks that need to run every hour"
  task hourly: []

  desc "All the tasks that need to run every day"
  task daily: [
    :"events:clean",
    :"events:pull",
    :"events:details:pull"
  ]
end

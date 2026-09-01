namespace :demo_data do
  desc "Populate the database with seeded demo accounts and content"
  task populate: :environment do
    DemoDataGenerator.call
  end

  desc "Remove seeded demo accounts and their associated content"
  task clear: :environment do
    users = User.where(seeded_account: true)

    puts "Removing #{users.count} seeded demo accounts..."

    users.destroy_all

    puts "Seeded demo accounts removed."
  end
end

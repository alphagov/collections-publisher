desc "Install dependencies before precompile"
task before_assets_precompile: :environment do
  system("yarn install")
end

Rake::Task["assets:precompile"].enhance %w(before_assets_precompile)

task :before_assets_precompile do
  # run a command which starts your packaging
  system('yarn install')
end

Rake::Task['assets:precompile'].enhance %w(before_assets_precompile)

require 'opal'
require 'opal-sprockets'

desc "Build our app to shoot40k_6_2.js"
task :build do
  env = Opal::Environment.new
  env.append_path "app"

  File.open("shoot40k_6_2.js", "w+") do |out|
    out << env["shoot40k_6_2"].to_s
  end
end

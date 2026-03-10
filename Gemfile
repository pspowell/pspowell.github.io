source "https://rubygems.org"

# Use the GitHub Pages dependency set
gem "github-pages", group: :jekyll_plugins

# Theme
gem "minima", "~> 2.5"

# Plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows / JRuby timezone support
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Windows file watching performance
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# JRuby compatibility
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
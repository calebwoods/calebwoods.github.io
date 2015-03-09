require 'jekyll/tagging'
require 'jekyll-sitemap'

module Jekyll
  module Filters
    def join(input, glue = ',')
      [input].flatten.join(glue)
    end
  end
end

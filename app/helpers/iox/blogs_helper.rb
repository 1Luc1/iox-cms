module Iox
  module BlogsHelper

    def tags
      tags = {}
      Blog.where(published: true).each do |blog|
        next if blog.translation.meta_keywords.blank?
        blog.translation.meta_keywords.split(',').each do |tag|
          tags[tag] ||= 0
          tags[tag] += 1
        end
      end
      return tags
    end

  end
end
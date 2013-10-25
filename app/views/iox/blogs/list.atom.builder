atom_feed :language => I18n.locale do |feed|
  feed.title Rails.configuration.iox.site_title
  feed.updated @blogs.last.updated_at
  feed.root_url blogs_url

  @blogs.each do |blog|
    feed.entry( blog ) do |entry|
      entry.url blog_url(blog)
      entry.title blog.translation.title
      entry.content blog.translation.content, :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(blog.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name blog.creator.full_name
      end

    end
  end
end
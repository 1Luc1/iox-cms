module Ion
  class WebpageStat < ActiveRecord::Base

    belongs_to :webpage, inverse_of: :stats

  end
end

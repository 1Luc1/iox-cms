module Iox
  class User < ActiveRecord::Base
    acts_as_iox_authoritive
  end
end
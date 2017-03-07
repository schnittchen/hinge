require "hinge/version"
require 'hinge/resolver'

module Hinge
  def self.resolver(container)
    Resolver.new(container)
  end
end

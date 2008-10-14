# ENV["RAILS_ENV"] = "production"
# require 'test/unit'
# require 'init'

# class TestableLoggerProdTest < Test::Unit::TestCase
  
#   # cases to test:
#   # * verify that testable logger is not active in dev and prod

#   def test_should_not_override_logger
#     if Object.const_defined? :RAILS_DEFAULT_LOGGER
#       assert RAILS_DEFAULT_LOGGER.is_a? Logger
#     end
#   end
#   def test_that_assertions_are_not_defined
#     assert_nothing_logged
#   end
# end

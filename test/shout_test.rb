gem 'minitest', '~>5.0'
require 'minitest/autorun'
require File.expand_path('../../examples/snowcone', __FILE__)
class ShoutTest < Minitest::Test
  def test_example
    snowcone = Barista.order(:blue_raspberry,:banana,:bubblegum)
    snowcone.purchase(5.00)
    snowcone.state!(:eaten)
    snowcone.state!(:thrown_away)
    assert_equal(
                 [
                  999, 
                  0,
                  [5.00],
                 ],
                 
                 [
                  INVENTORY[:ice],
                  INVENTORY[:banana_syrup],
                  BANK_ACCOUNT[:credits],
                 ]
                 )
  end
end

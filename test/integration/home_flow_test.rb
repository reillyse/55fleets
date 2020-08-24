require 'test_helper'

class HomeFlowTest < ActionDispatch::IntegrationTest
  test 'home page' do
    visit home_path
    assert page.has_content?('BALLSx')
    assert page.has_content?('Deploy Your Docker Applications in Minutes')
    assert page.has_content?(
             'Enjoy the power of docker with the ease of automatic deployment and scaling'
           )
  end
end

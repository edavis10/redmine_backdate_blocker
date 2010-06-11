require 'test_helper'

class ConfiguringTest < ActionController::IntegrationTest
  include IntegrationTestHelper

  setup do
    User.current = nil
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
  end

  should "use the currently saved setting" do
    Setting['plugin_redmine_backdate_blocker'] = {'days' => '10'}
    
    login_as
    visit_plugin_configuration
    assert_select '#settings_days[value=?]', /10/
  end
  

  should "save any content to the plugin's settings" do
    login_as
    visit_plugin_configuration

    fill_in "settings_days", :with => '14'
    click_button 'Apply'

    assert_equal "http://www.example.com/settings/plugin/redmine_backdate_blocker", current_url
    assert_select '#settings_days[value=?]', /14/

  end
  
  protected
  
  def visit_plugin_configuration
    click_link "Administration"
    click_link "Plugins"
    click_link "Configure"

    assert_equal "/settings/plugin/redmine_backdate_blocker", current_url
  end
  
end


require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineBackdateBlocker::Patches::TimeEntryTest < ActionController::TestCase

  context "TimeEntry should be patched to" do
    setup do
      @user = User.generate!
      @project = Project.generate!
      @role = Role.generate!(:permissions => [:log_time, :view_time_entries, :edit_time_entries])
      @member = Member.generate!(:principal => @user, :roles => [@role], :project => @project)
      @activity = TimeEntryActivity.generate!
      
      @valid_attributes = {
        :project => @project,
        :user => @user,
        :activity => @activity,
        :hours => 10
      }
      User.current = @user
    end
    
    should "allow creating one in the future" do
      time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => 1.day.from_now))
      assert time_entry.save
    end

    should "allow creating one today" do
      time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => Date.today))
      assert time_entry.save
    end

    should "allow creating up to the backdated number of days" do
      spent_on = Setting.plugin_redmine_backdate_blocker['days'].to_i.days.ago
      time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => spent_on))
      assert time_entry.save
    end

    context "for an administrator" do
      should "allow creating past the backdated number of days" do
        @user.update_attribute(:admin, true)
        assert @member.destroy # Non-member but admin
        time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => 1.year.ago))
        assert time_entry.save
      end
    end

    context "for an authorized user" do
      should "allow creating past the backdated number of days" do
        @role.update_attribute(:permissions, [:log_time, :view_time_entries, :edit_time_entries, :backdate_time])
        
        time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => 1.year.ago))
        assert time_entry.save
      end
      
    end

    context "for an unauthorized user" do
      should "not allow creating past the backdated number of days" do
        time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => 1.year.ago))

        assert !time_entry.save
        assert_match /Time may not be clocked prior to /, time_entry.errors.on_base
      end

      should "allow logging on the same day, even if the current time makes it appear off" do
        time_entry = TimeEntry.new(@valid_attributes.merge(:spent_on => 3.days.ago - 10.seconds))

        assert time_entry.save
      end
    end
  end
end

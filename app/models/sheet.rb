# And active worksheet, linked to a task and a user

class Sheet < ActiveRecord::Base
  belongs_to :task, :class_name => '::Task'
  belongs_to :project, :class_name => '::Project'
  belongs_to :user, :class_name => '::User'

  def paused?
    self.paused_at != nil
  end

  def duration
    d = (Time.now.utc - self.created_at).to_i
    d = d - (Time.now.utc - self.paused_at).to_i unless self.paused_at.nil?
    d = d - (self.paused_duration)
  end

end

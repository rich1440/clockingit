# A chat message in a chat channel

class Shout < ActiveRecord::Base
  belongs_to :shout_channel
  belongs_to :company
  belongs_to :user

	if RUBY_PLATFORM =~ /java/
  acts_as_solr
		else
  acts_as_ferret({ :fields => { 'company_id' => {},
    'shout_channel_id' => {},
    'body' => { :boost => 1.5 },
    'message_type' => {},
    'nick' => { }
	 }, :remote => true
  })
end


  def self.full_text_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 20, :page => 1}
    options = default_options.merge options
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)
    isJRuby = RUBY_PLATFORM =~ /java/
    results = WorkLog.find_with_ferret(q, options)  if !isJRuby
    results = WorkLog.find_with_solr(q, options)  if isJRuby
    return [results.total_hits, results]
  end

end

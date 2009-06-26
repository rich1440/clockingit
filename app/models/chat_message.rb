# A single instant message between two users.

class ChatMessage < ActiveRecord::Base
	belongs_to :chat
	belongs_to :user
  
	if RUBY_PLATFORM =~ /java/
		acts_as_solr
	else
		acts_as_ferret({ :fields => { 'chat_id' => {},
				'body' => { :boost => 1.5 }
			}, :remote => true
		})
        end

end

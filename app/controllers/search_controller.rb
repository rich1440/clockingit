# Search across all WorkLogs and Tasks
class SearchController < ApplicationController

	def search

		@tasks = []
		@logs = []
		@shouts = []

		return if params[:query].nil? || params[:query].length == 0

		@keys = params[:query].split(' ')
		@keys ||= []
    
		# TODO _rgs_ entering #n in search box will find a task task #n.
		# Looking up a task by number?
		task_num = params[:query][/#[0-9]+/]
		unless task_num.nil?
			@tasks = Task.find(:all, :conditions => ["company_id = ? AND project_id IN (#{current_project_ids}) AND task_num = ?", current_user.company_id, task_num[1..-1]])
			redirect_to :controller => 'tasks', :action => 'edit', :id => @tasks.first
		end

		is_jruby = RUBY_PLATFORM =~ /java/

		query = ""
		# _rgs_ just make a query string like +rich +spencer +solr
		@keys.each do |k|
			if is_jruby
				query << "+#{k} "
			else
				query << "+*:#{k}* "
			end

		end

		session[:completed_projects] = params[:completed_projects] if request.post?
    
		if session[:completed_projects].to_i == 1
			target_projects = all_projects
		end
		target_projects ||= current_projects
=begin
# _rgs_ This little code snippet is very handy for debugging solr requests
require 'uri'
url = "grabbed from debug local variables in acts_as_solr, line 47, request"
s = URI.unescape(url)
puts s
=end
		projects = ""
		if is_jruby && target_projects != ""
			projects = "("
			target_projects.each do |p|
				projects << " OR " unless projects == "("
				projects << "project_id:#{p.id}"
			end
			projects << ")"
		else
			target_projects.each do |p| 
				projects << "|" unless projects == ""
				projects << "#{p.id}"
			end 
			projects = "+project_id:\"#{projects}\"" unless projects == ""
		end


		@tasks = Task.find_with_ferret("+company_id:#{current_user.company_id} #{projects} #{query}", {:limit => 1000}) if !is_jruby
		if is_jruby
			@tasks = Task.find_by_solr("+company_id:#{current_user.company_id} AND #{projects} AND #{query}", {:limit => 1000})
			@tasks = @tasks.results
		end


		# Find the worklogs
		@logs = WorkLog.find_with_ferret("+company_id:#{current_user.company_id} #{projects} #{query}", {:limit => 1000}) if !is_jruby
		if is_jruby
			@logs = WorkLog.find_by_solr("+company_id:#{current_user.company_id} AND #{projects} AND #{query}", {:limit => 1000})
			@logs = @logs.results
		end

		# TODO _rgs_ update Find chat messages to work with Solr
		rooms = ""
		ShoutChannel.find(:all, :conditions => ["(company_id = ?) AND (project_id IS NULL OR project_id IN (#{current_project_ids}))", current_user.company_id],
			:order => "company_id, project_id, name").each do |r|
			rooms << "|" unless rooms == ""
			rooms << "#{r.id}"
		end
		rooms = "0" if rooms == ""
		rooms = "+shout_channel_id:\"#{rooms}\" +message_type:0"
		@shouts = Shout.find_with_ferret("+company_id:#{current_user.company_id} #{rooms} #{query}", {:limit => 100}) if !is_jruby
		if is_jruby
			@shouts = Shout.find_by_solr("+company_id:#{current_user.company_id} AND #{query}", {:limit => 100})
			@shouts = @shouts.results
		end


		# Find Wikis
		@wiki_pages = WikiPage.find_with_ferret("+company_id:#{current_user.company_id} #{query}", {:limit => 100}) if !is_jruby
		if is_jruby
			@wiki_pages = WikiPage.find_by_solr("+company_id:#{current_user.company_id} AND #{query}", {:limit => 100})
			@wiki_pages = @wiki_pages.results
		end


		# Find posts
		forums = ""
		Forum.find(:all, :conditions => ["(company_id = ?) AND (project_id IS NULL OR project_id IN (#{current_project_ids}))", current_user.company_id],
			:order => "company_id, project_id, name").each do |f|
			forums << "|" unless forums == ""
			forums << "#{f.id}"
		end

		# TODO _rgs_ update Find forums to work with Solr
		forums = "+forum_id:\"#{forums}\""
		@posts = Post.find_with_ferret("+company_id:#{current_user.company_id} #{forums} #{query}", {:limit => 100}) if !is_jruby
		if is_jruby
			@posts = Post.find_by_solr("#{forums} #{query}", {:limit => 100})
			@posts = @posts.results
		end
		# TODO _rgs_ update chat find to work with Solr
		chats = ""
		Chat.find(:all, :conditions => ["user_id = ?", current_user.id]).each do |c|
			chats << "|" unless chats == ""
			chats << "#{c.id}"
		end
		chats = "0" if chats == ""
		chats = "+chat_id:\"#{chats}\""
		@chat_messages = ChatMessage.find_with_ferret("#{chats} #{query}", {:limit => 100}) if !is_jruby
		if is_jruby
			@chat_messages = ChatMessage.find_by_solr("#{chats} #{query}", {:limit => 100})
			@chat_messages = @chat_messages.results
		end
    
		# Find customers
		@customers = Customer.search(current_user.company, @keys)

		# Find users
		@users = User.search(current_user.company, @keys)
	end
end

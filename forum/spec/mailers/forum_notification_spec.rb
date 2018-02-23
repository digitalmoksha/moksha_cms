require 'spec_helper'

describe ForumNotificationMailer, type: :mailer do
  include ActiveJob::TestHelper

  setup_account

  let(:user) { create :user }
  let(:forum_site) { create :forum_site }
  let(:forum) { create :forum, forum_site: forum_site }
  let(:topic) { create :forum_topic, user: user, forum: forum, body: 'initial comment text' }
  let(:comment) { create :comment, commentable: topic, user: user }

  it 'job is created and enqueued' do
    ActiveJob::Base.queue_adapter = :test
    expect {
      ForumNotificationMailer.follower_notification(user, topic, [comment]).deliver_later
    }.to have_enqueued_job.on_queue('mailers')
  end

  # since we have config.action_mailer.delivery_method  set to :test in our :test.rb,
  # all 'sent' emails are gathered into the ActionMailer::Base.deliveries array.
  it 'notification is sent' do
    expect {
      perform_enqueued_jobs do
        ForumNotificationMailer.follower_notification(user, topic, [comment]).deliver_later
      end
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'notification is sent to the right user' do
    perform_enqueued_jobs do
      ForumNotificationMailer.follower_notification(user, topic, [comment]).deliver_later
    end

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to[0]).to eq user.email
  end

  it 'notification contains correct subject' do
    perform_enqueued_jobs do
      ForumNotificationMailer.follower_notification(user, topic, [comment]).deliver_later
    end

    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to include "Comments: #{topic.title}"
  end
end
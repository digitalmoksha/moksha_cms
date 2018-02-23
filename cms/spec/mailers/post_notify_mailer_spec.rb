require 'spec_helper'

describe PostNotifyMailer, type: :mailer do
  include ActiveJob::TestHelper

  setup_account

  let(:user) { create :user }
  let(:blog) { create :blog }
  let(:post) { create :post, cms_blog: blog }

  it 'job is created and enqueued' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        PostNotifyMailer.post_notify(user, post, post.account).deliver_later
      }.to have_enqueued_job.on_queue('mailers')
  end

  # since we have config.action_mailer.delivery_method  set to :test in our :test.rb,
  # all 'sent' emails are gathered into the ActionMailer::Base.deliveries array.
  it 'notification is sent' do
      expect {
          perform_enqueued_jobs do
            PostNotifyMailer.post_notify(user, post, post.account).deliver_later
          end
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it 'notification is sent to the right user' do
      perform_enqueued_jobs do
        PostNotifyMailer.post_notify(user, post, post.account).deliver_later
      end

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq user.email
  end

  it 'notification contains correct subject' do
      perform_enqueued_jobs do
        PostNotifyMailer.post_notify(user, post, post.account).deliver_later
      end

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include "Blog: #{post.cms_blog.title} :: #{post.title}"
  end
end
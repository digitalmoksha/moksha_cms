require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe DmForum::SendCommentNotificationService, type: :service do
  include ActiveJob::TestHelper
  setup_account

  let(:user) { create :user }
  let(:forum_site) { create :forum_site }
  let(:forum) { create :forum, forum_site: forum_site }
  let(:topic) { create :forum_topic, user: user, forum: forum, body: 'initial comment text' }
  let(:comment) { create :comment, commentable: topic, user: user }

  describe '#call' do
    let!(:service) { described_class.new(comment) }

    it 'is attached to a ForumTopic' do
      expect(comment.commentable_type).to eq 'ForumTopic'
      expect(comment.commentable_id).to eq topic.id
    end

    describe 'notifies followers' do
      # assumes ActiveJob::Base.queue_adapter = :test is set
      it 'sends nothing if there are no followers' do
        expect do
          perform_enqueued_jobs { service.call }
        end.to change(ActionMailer::Base.deliveries, :count).by(0)
      end

      it 'sends notifications to followers' do
        user.following.follow(topic)
        user.reload

        expect do
          perform_enqueued_jobs { service.call }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end

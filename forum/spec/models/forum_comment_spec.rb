require 'spec_helper'
DmCore.config.locales = [:en, :de]

describe ForumComment do
  setup_account

  let(:user) { create :user }
  let(:forum_site) { create :forum_site }
  let(:forum) { create :forum, forum_site: forum_site }
  let(:topic) { create :forum_topic, user: user, forum: forum, body: 'initial comment text' }
  let(:comment) { create :comment, commentable: topic, user: user }

  it 'is attached to a ForumTopic' do
    expect(comment.commentable_type).to eq 'ForumTopic'
    expect(comment.commentable_id).to eq topic.id
  end
end

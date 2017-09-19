shared_examples :public_private_protected do |factory|
  let(:model) { described_class }

  context "visibility of #{described_class}" do
    let(:built) { build factory }

    describe '#is_public?' do
      it 'is public' do
        built.is_public = true
        built.requires_login = false
        expect(built.is_public?).to be_truthy
      end
    
      it 'is not public' do
        built.is_public = false
        built.requires_login = false
        expect(built.is_public?).to be_falsy

        built.requires_login = true
        expect(built.is_public?).to be_falsy
      end
    end

    describe '#is_protected?' do
      it 'is protected' do
        built.is_public = true
        built.requires_login = true
        expect(built.is_protected?).to be_truthy
      end
    
      it 'is not protected' do
        built.is_public = false
        built.requires_login = false
        expect(built.is_protected?).to be_falsy

        built.requires_login = true
        expect(built.is_protected?).to be_falsy
      end
    end

    describe '#is_private?' do
      it 'is private' do
        built.is_public = false
        built.requires_login = false
        built.requires_subscription = false
        expect(built.is_private?).to be_truthy

        built.is_public = false
        built.requires_login = true
        built.requires_subscription = false
        expect(built.is_private?).to be_truthy

        built.is_public = false
        built.requires_login = false
        built.requires_subscription = true
        expect(built.is_private?).to be_truthy

      end
    
      it 'is not private' do
        built.is_public = true
        built.requires_login = false
        built.requires_subscription = false
        expect(built.is_private?).to be_falsy

        built.is_public = true
        built.requires_login = false
        built.requires_subscription = true
        expect(built.is_private?).to be_falsy
      end
    end

    describe '#is_subscription_only?' do
      it 'is subscription only' do
        built.requires_subscription = true
        expect(built.is_subscription_only?).to be_truthy
      end

      it 'is not subscription only' do
        built.requires_subscription = false
        expect(built.is_subscription_only?).to be_falsy
      end
    end

    it '#visibility_to_s' do
      built.is_public = true
      built.requires_login = false
      expect(built.visibility_to_s).to eq 'public'

      built.is_public = true
      built.requires_login = true
      expect(built.visibility_to_s).to eq 'protected'
    
      built.is_public = true
      built.requires_login = true
      built.requires_subscription = true
      expect(built.visibility_to_s).to eq 'subscription'
    
      built.is_public = false
      built.requires_login = false
      built.requires_subscription = false
      expect(built.visibility_to_s).to eq 'private'
    end
  end  

  context "membership and access to #{described_class}" do
    let(:created) { create factory}
    let(:user)    { create :user }

    it '#add_member' do
      expect(created.member?(user)).to be_falsy
      created.add_member(user)
      expect(created.member?(user)).to be_truthy
    end

    it '#remove_member' do
      created.add_member(user)
      expect(created.member?(user)).to be_truthy
      created.remove_member(user)
      expect(created.member?(user)).to be_falsy
    end
    
    describe '#member_count' do
      it 'counts manually added members' do
        created.add_member(user)
        created.add_member(create :user)
        expect(created.member_count).to eq 2
        expect(created.member_count(:manual)).to eq 2
      end
      
      it 'counts automatic members with an owner' do
        allow(user).to receive(:member_count).and_return(10)
        created.owner = user
        expect(created.member_count(:automatic)).to eq 10
      end

      it 'counts automatic members without an owner' do
        expect(created.member_count(:automatic)).to eq 0
      end
    end

    describe '#member_list' do
      it 'counts manually added members' do
        created.add_member(user)
        expect(created.member_list).to eq [user]
        expect(created.member_list(:manual)).to eq [user]
      end
      
      it 'counts automatic members with an owner' do
        allow(user).to receive(:member_list).and_return([1, 2])
        created.owner = user
        expect(created.member_list(:automatic)).to eq [1, 2]
      end

      it 'counts automatic members without an owner' do
        expect(created.member_list(:automatic)).to eq []
      end
    end
    
    describe 'can_be_read_by?' do
      it 'not if unpublished' do
        created.published = false
        expect(created.can_be_read_by?(user)).to be_falsy
      end

      it 'only public can be read by anonymous user' do
        created.is_public = true
        expect(created.can_be_read_by?(nil)).to be_truthy
        created.is_public = false
        expect(created.can_be_read_by?(nil)).to be_falsy
        created.is_public = true
        created.requires_login = true
        expect(created.can_be_read_by?(nil)).to be_falsy
      end

      it 'if public' do
        created.is_public = true
        expect(created.can_be_read_by?(user)).to be_truthy
      end

      it 'if protected' do
        created.is_public = true
        created.requires_login = true
        expect(created.can_be_read_by?(user)).to be_truthy
      end

      it 'not by a normal user if private' do
        created.is_public = false
        expect(created.can_be_read_by?(user)).to be_falsy
      end

      it 'an admin can read private' do
        created.is_public = false
        allow(user).to receive(:is_admin?).and_return(true)
        expect(created.can_be_read_by?(user)).to be_truthy
      end

      it 'an member can read private' do
        created.is_public = false
        created.add_member(user)
        expect(created.can_be_read_by?(user)).to be_truthy
      end

      it 'if is a paid subscriber' do
        created.is_public = false
        created.requires_subscription = true
        allow(user).to receive(:is_paid_subscriber?).and_return(true)
        expect(created.can_be_read_by?(user)).to be_truthy

        allow(user).to receive(:is_paid_subscriber?).and_return(false)
        expect(created.can_be_read_by?(user)).to be_falsy
      end
    end

    describe 'can_be_replied_by?' do
      it 'not if unpublished' do
        created.published = false
        expect(created.can_be_replied_by?(user)).to be_falsy
      end

      it 'not by an anonymous user' do
        created.is_public = true
        expect(created.can_be_replied_by?(nil)).to be_falsy
        created.is_public = false
        expect(created.can_be_replied_by?(nil)).to be_falsy
      end

      it 'if public' do
        created.is_public = true
        expect(created.can_be_replied_by?(user)).to be_truthy
      end

      it 'if protected' do
        created.is_public = true
        created.requires_login = true
        expect(created.can_be_replied_by?(user)).to be_truthy
      end

      it 'not by a normal user if private' do
        created.is_public = false
        expect(created.can_be_replied_by?(user)).to be_falsy
      end

      it 'an admin can read private' do
        created.is_public = false
        allow(user).to receive(:is_admin?).and_return(true)
        expect(created.can_be_replied_by?(user)).to be_truthy
      end

      it 'an member can read private' do
        created.is_public = false
        created.add_member(user)
        expect(created.can_be_replied_by?(user)).to be_truthy
      end

      it 'if is a paid subscriber' do
        created.is_public = false
        created.requires_subscription = true
        allow(user).to receive(:is_paid_subscriber?).and_return(true)
        expect(created.can_be_replied_by?(user)).to be_truthy

        allow(user).to receive(:is_paid_subscriber?).and_return(false)
        expect(created.can_be_replied_by?(user)).to be_falsy
      end
    end
    
    describe 'available_to_user' do
      let!(:unpublished_obj) { create factory, is_public: true, published: false }
      let!(:public_obj) { create factory, is_public: true }
      let!(:protected_obj) { create factory, is_public: true, requires_login: true }
      let!(:private_obj) { create factory, is_public: false }
      let!(:subscribed_obj) { create factory, is_public: false, requires_subscription: true }

      it 'anoymous user only gets published and public' do
        expect(described_class.available_to_user(nil)).to eq [public_obj]
      end

      it 'admin gets them all' do
        allow(user).to receive(:is_admin?).and_return(true)
        expect(described_class.available_to_user(user)).to match_array([unpublished_obj, public_obj, protected_obj, private_obj, subscribed_obj])
      end

      it 'only protected and public' do
        expect(described_class.available_to_user(user)).to match_array([public_obj, protected_obj])
      end

      it 'includes private if a member' do
        private_obj.add_member(user)
        expect(described_class.available_to_user(user)).to match_array([public_obj, protected_obj, private_obj])
      end

      it 'includes subscriptions is paid' do
        allow(user).to receive(:is_paid_subscriber?).and_return(true)
        expect(described_class.available_to_user(user)).to match_array([public_obj, protected_obj, subscribed_obj])
      end
    end
  end
end

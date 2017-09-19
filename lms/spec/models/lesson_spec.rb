require 'spec_helper'

describe Lesson do
  setup_account
  
  it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  it { is_expected.to validate_length_of(:title_en).is_at_most(255) }
  it { is_expected.to validate_length_of(:menutitle_en).is_at_most(255) }

  describe 'slug handling' do
    let(:course1) { create(:course) }
    let(:course2) { create(:training_course)}

    #------------------------------------------------------------------------------
    it 'allows the same specified slug between two courses (scoped to course)' do
      lesson1 = create(:lesson, course: course1)
      lesson2 = create(:lesson, course: course2)
      expect(lesson1.slug).to eq lesson2.slug
    end

    #------------------------------------------------------------------------------
    it 'allows the same auto-generated slug between two courses (scoped to courses)' do
      lesson1 = create(:lesson, course: course1, slug: nil)
      lesson2 = create(:lesson, course: course2, slug: nil)
      expect(lesson1.slug).to eq lesson2.slug
    end

    #------------------------------------------------------------------------------
    it 'raises an error when same slug is specified for lessons in the same course' do
      lesson1 = create(:lesson, course: course1, slug: 'test-slug')
      lesson2 = build(:lesson, course: course1, slug: 'test-slug')
      expect(lesson2).not_to be_valid
      expect(lesson2.errors[:slug]).to include("has already been taken")
    end

    #------------------------------------------------------------------------------
    it 'creates a unique auto-generated slug for lessons in the same course' do
      lesson1 = create(:lesson, course: course1, slug: nil)
      lesson2 = create(:lesson, course: course1, slug: nil)
      expect(lesson1.slug).not_to eq lesson2.slug
    end
  end
  
  describe 'next/previous' do
    let(:course1) { create(:course) }
    
    #------------------------------------------------------------------------------
    it '#next published lesson' do
      lesson1 = create(:lesson,   course: course1, published: true)
      lesson2 = create(:lesson_2, course: course1, published: true)
      lesson3 = create(:lesson_3, course: course1, published: false)
      expect(lesson1.next).to eq lesson2
      expect(lesson2.next).to eq nil
    end

    #------------------------------------------------------------------------------
    it '#next unpublished lesson' do
      lesson1 = create(:lesson,   course: course1, published: true)
      lesson2 = create(:lesson_2, course: course1, published: false)
      expect(lesson1.next(published_only: false)).to eq lesson2
    end

    #------------------------------------------------------------------------------
    it '#previous published lesson' do
      lesson1 = create(:lesson,   course: course1, published: false)
      lesson2 = create(:lesson_2, course: course1, published: true)
      lesson3 = create(:lesson_3, course: course1, published: true)
      expect(lesson1.previous).to eq nil
      expect(lesson2.previous).to eq nil
      expect(lesson3.previous).to eq lesson2
    end

    #------------------------------------------------------------------------------
    it '#previous unpublished lesson' do
      lesson1 = create(:lesson,   course: course1, published: false)
      lesson2 = create(:lesson_2, course: course1, published: true)
      expect(lesson2.previous(published_only: false)).to eq lesson1
    end
  end

end
require 'spec_helper'

describe LessonPage do
  setup_account

  it { is_expected.to validate_length_of(:slug).is_at_most(255) }

  describe 'slug handling' do
    let(:course)  { create(:course) }
    let(:lesson1) { create(:lesson,   course: course, published: true) }
    let(:lesson2) { create(:lesson_2, course: course, published: true) }

    #------------------------------------------------------------------------------
    it 'allows the same specified slug between two lessons (scoped to lesson)' do
      teaching1 = create(:teaching)
      teaching2 = create(:teaching)
      page1 = create(:lesson_page, lesson: lesson1, item: teaching1)
      page2 = create(:lesson_page, lesson: lesson2, item: teaching2)
      expect(page1.slug).to eq page2.slug
    end

    #------------------------------------------------------------------------------
    it 'allows the same auto-generated slug between two lessons (scoped to lesson)' do
      teaching1 = create(:teaching)
      teaching2 = create(:teaching)
      page1 = create(:lesson_page, lesson: lesson1, item: teaching1, slug: nil)
      page2 = create(:lesson_page, lesson: lesson2, item: teaching2, slug: nil)
      expect(page1.slug).to eq page2.slug
    end

    #------------------------------------------------------------------------------
    it 'raises an error when same slug is specified for lessons in the same course' do
      teaching1 = create(:teaching)
      teaching2 = create(:teaching)
      page1 = create(:lesson_page, lesson: lesson1, item: teaching1, slug: 'test')
      page2 = build(:lesson_page, lesson: lesson1, item: teaching2, slug: 'test')
      expect(page2).not_to be_valid
      expect(page2.errors[:slug]).to include("has already been taken")
    end

    #------------------------------------------------------------------------------
    it 'creates a unique auto-generated slug for lessons in the same course' do
      teaching1 = create(:teaching)
      teaching2 = create(:teaching)
      page1 = create(:lesson_page, lesson: lesson1, item: teaching1, slug: nil)
      page2 = create(:lesson_page, lesson: lesson1, item: teaching2, slug: nil)
      expect(lesson1.slug).not_to eq lesson2.slug
    end
  end

  describe 'next/previous' do
    let(:course)  { create(:course) }
    let(:lesson)  { create(:lesson,   course: course, published: true) }
    let(:lesson2) { create(:lesson_2, course: course, published: true) }
    let(:lesson3) { create(:lesson_3, course: course, published: false) }

    #------------------------------------------------------------------------------
    it '#next published lesson_page' do
      page1 = create(:lesson_page,   lesson: lesson, published: true, item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson, published: true, item: create(:teaching_2))
      page3 = create(:lesson_page_3, lesson: lesson, published: false, item: create(:teaching_3))
      expect(page1.next).to eq page2
      expect(page2.next).to eq nil
    end

    #------------------------------------------------------------------------------
    it '#next unpublished lesson_page' do
      page1 = create(:lesson_page,   lesson: lesson, published: true, item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson, published: false, item: create(:teaching_2))
      expect(page1.next(published_only: false)).to eq page2
    end

    #------------------------------------------------------------------------------
    it '#previous published lesson_page' do
      page1 = create(:lesson_page,   lesson: lesson, published: false, item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson, published: true, item: create(:teaching_2))
      page3 = create(:lesson_page_3, lesson: lesson, published: true, item: create(:teaching_3))
      expect(page1.previous).to eq nil
      expect(page2.previous).to eq nil
      expect(page3.previous).to eq page2
    end

    #------------------------------------------------------------------------------
    it '#previous unpublished lesson_page' do
      page1 = create(:lesson_page,   lesson: lesson, published: true, item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson, published: false, item: create(:teaching_2))
      expect(page2.previous(published_only: false)).to eq page1
    end

    #------------------------------------------------------------------------------
    it '#next published lesson_page in the next lesson' do
      page1 = create(:lesson_page,   lesson: lesson,  published: true,  item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson2, published: true,  item: create(:teaching_2))
      page3 = create(:lesson_page_3, lesson: lesson3, published: false, item: create(:teaching_3))
      expect(page1.next).to eq page2
      expect(page2.next).to eq nil
      expect(page2.next(published_only: false)).to eq page3
    end

    #------------------------------------------------------------------------------
    it '#previous published lesson_page in the previous lesson' do
      lesson.published = false
      lesson.save
      page1 = create(:lesson_page,   lesson: lesson,  published: false, item: create(:teaching))
      page2 = create(:lesson_page_2, lesson: lesson2, published: true, item: create(:teaching_2))
      page3 = create(:lesson_page_3, lesson: lesson3, published: true, item: create(:teaching_3))
      expect(page3.previous).to eq page2
      expect(page2.previous).to eq nil
      expect(page2.previous(published_only: false)).to eq page1
    end
  end
end

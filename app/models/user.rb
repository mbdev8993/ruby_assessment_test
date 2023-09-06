class User < ApplicationRecord
  enum kinds: {'Student'=>0, 'Teacher'=>1, 'student_teacher'=>2}

  has_many :enrollments, foreign_key: :user_id

  has_many :teacher_enrollments, foreign_key: :teacher_id, class_name: 'Enrollment'
  has_many :student_programs, through: :enrollments, source: :program
  has_many :teacher_programs, through: :teacher_enrollments, source: :program

  has_many :teachers, through: :student_programs, source: :teachers


  validate :check_for_valid_transition, on: :update

  def classmates
    User.joins(:enrollments).where(enrollments: {program_id: student_programs.pluck(:id)}).where.not(id: id).distinct
  end

  def favorite_teachers
    enrollments.where(favorite: true).map(&:teacher)
  end

  def teacher?
    kind == 1
  end

  def student?
    kind == 0
  end

  def teacher_student?
    kind == 2
  end

  private
  def check_for_valid_transition
    if teacher? && teacher_programs.present?
        errors.add(:base, "Kind can not be student because is teaching in at least one program")
    elsif student? && student_programs.present?
        errors.add(:base, "Kind can not be teacher because is studying in at least one program")
    elsif teacher_student? && teacher_programs.present? && student_programs.present?
        errors.add(:base, "Kind can not be student/teacher because is teaching/studying in at least one program")
    end
  end
end

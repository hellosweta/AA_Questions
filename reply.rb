require 'sqlite3'
require_relative 'questions'

class Reply
  attr_accessor :id, :subject_question_id, :parent_reply_id, :user_id, :body

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(subject_question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, subject_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL
    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    user = User.find_by_id(@user_id)
    return nil if user.nil?
    user
  end

  def question
    question = Question.find_by_id(@subject_question_id)
    return nil if question.nil?
    question
  end

  def parent_reply
    reply = Reply.find_by_id(@parent_reply_id)
    return nil if reply.nil?
    reply
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id, @subject_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ? AND subject_question_id = ?
    SQL
    return nil if reply.empty?
    Reply.new(reply.first)
  end
end

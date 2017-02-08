require 'sqlite3'
require_relative 'questions'


class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    questions = Question.find_by_author_id(@id)
    return nil if questions.empty?
    questions
  end

  def authored_replies
    replies = Reply.find_by_user_id(@id)
    return nil if replies.empty?
    replies
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT

        COUNT(DISTINCT(question_likes.question_id)) AS number_of_questions,
        COUNT(question_likes.user_id) AS likes,
        -- CAST(likes AS FLOAT)/number_of_questions AS average_karma
        CAST(COUNT(question_likes.user_id) AS FLOAT)/COUNT(DISTINCT(question_likes.question_id)) AS average_karma
      FROM
        questions
        LEFT OUTER JOIN question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.associated_author_id = ?
    SQL

    karma.first['average_karma']
  end

  def save

    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @body, @associated_author_id)
        INSERT INTO
          questions (fname, body, associated_author_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @body, @associated_author_id, @id)
        UPDATE
          questions
        SET
          fname = ?, body = ?, associated_author_id = ?
        WHERE
          id = ?
      SQL
    end

  end
end

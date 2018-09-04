require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
  attr_accessor :fname, :lname
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(user.first)
  end
  
  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    Users.new(user.first)
  end
  
  def authored_questions
    Question.find_by_author(@id)
  end
end

class Question
  attr_accessor :title, :body, :user_id
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end
  
  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(question.first)
  end
  
  def self.find_by_author(user_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
    result = []
    question.each do |hash|
      result << Question.new(hash)
    end
    result
  end
  
end

class Reply
  attr_accessor :question_id, :body, :parent_id, :user_id
  
  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @body = options['body']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
  
  def self.find_by_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Reply.new(reply.first)
  end
  
  def self.find_by_user_id(user_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    result = []
    
    reply.each do |hash|
      result << Reply.new(hash)
    end
    result
  end
  
  def self.find_by_question_id(question_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
      SQL
    result = []
    
    reply.each do |hash|
      result << Reply.new(hash)
    end
    
    result
  end
  
end

class QuestionFollow
  attr_accessor :user_id, :question_id
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollow.new(question.first)
  end
  
end

class QuestionLike
  attr_accessor :user_id, :question_id
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    QuestionLike.new(question.first)
  end
  
end
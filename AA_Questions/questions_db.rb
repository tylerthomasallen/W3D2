require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDBConnection < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
  
  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
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
    User.new(user.first)
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
    User.new(user.first)
  end
  
  def authored_questions
    Question.find_by_author(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
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
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  
  def followers
    QuestionFollow.followers_for_question(@id)
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
  
  def author
    author = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
      SQL
    User.new(author.first)
  end
  
  def question
    question = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(question.first)
  end
  
  def parent_reply
    reply = QuestionsDBConnection.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Reply.new(reply.first)
  end
  
  def child_replies
    replies = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    
    result = []
    replies.each do |hash|
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
  
  def self.most_followed_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON users.id = question_follows.user_id
    JOIN
      questions ON question_follows.question_id = questions.id
    GROUP BY
      questions.body
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    
    questions.map{|hash| Question.new(hash) }
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
  
  def self.followers_for_question(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON users.id = question_follows.user_id
    JOIN
      questions ON question_follows.question_id = questions.id
    WHERE
      question_id = ?
    SQL
    
    users.map { |hash| User.new(hash) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON users.id = question_follows.user_id
    JOIN
      questions ON question_follows.question_id = questions.id
    WHERE
      users.id = ?
    SQL
    
    questions.map { |hash| Question.new(hash) }
    
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
  
  def self.most_liked_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      users
    JOIN
      question_likes ON users.id = question_likes.user_id
    JOIN
      questions ON question_likes.question_id = questions.id
    GROUP BY
      questions.body
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    
    questions.map{|hash| Question.new(hash) }
  end
  
  def self.likers_for_question_id(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_likes ON users.id = question_likes.user_id
    JOIN
      questions ON question_likes.question_id = questions.id
    WHERE
      questions.id = ?
    SQL
    
    users.map { |hash| User.new(hash)}
  end
  
  def self.num_likes_for_question_id(question_id)
    num = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*)
    FROM
      users
    JOIN
      question_likes ON users.id = question_likes.user_id
    JOIN
      questions ON question_likes.question_id = questions.id
    GROUP BY
      question_id
    HAVING
      question_id = ?
    SQL
    num.first.values.first
  end
  
  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_likes ON users.id = question_likes.user_id
    JOIN
      questions ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_id = ?
    SQL
    
    questions.map{ |hash| Question.new(hash) }
  end
end
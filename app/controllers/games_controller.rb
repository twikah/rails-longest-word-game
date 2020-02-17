require 'net/http'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @letters = params[:letters].split
    @word = params[:word].upcase
    session[:total] ||= 0
    if check_grid(@word, @letters)
      if check_word(@word)['found']
        @score = check_word(@word)['length']
        session[:total] += @score
        @total = "Your total score is #{session[:total]}."
        @result = "Congratulations! #{@word} is a valid English word! This is worth #{@score}."
      else
        @result = "Sorry but #{@word} does not seem to be a valid English word..."
        reset_score
        @total = "Your total score is #{session[:total]}."
      end
    else
      @result = "Sorry but #{@word} can't be built out of #{@letters}."
      reset_score
      @total = "Your total score is #{session[:total]}."
    end
  end

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def check_grid(word, letters)
    word.chars.all? do |letter|
      letters.delete_at(letters.index(letter)) if letters.include? letter
    end
  end

  def reset_score
    session[:total] = 0
  end
end

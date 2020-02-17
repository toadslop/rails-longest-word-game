require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (('a'..'z').to_a.sample(8) + %w[a e i o u].sample(2)).shuffle
  end

  def score
    time = (100 - (Time.now - Time.parse(params[:start]))) / 100
    letters = params[:letters].split(' ')
    answer = params[:answer].downcase
    possible = check_valid(answer, letters)
    found = word?(answer)
    @result = make_message(possible, found, answer)
    @score = possible && found ? score_answer(answer, time) : 0
  end

  private

  def check_valid(answer, letters)
    split = answer.split('')
    split.all? { |letter| split.count(letter) <= letters.count(letter) }
  end

  def word?(answer)
    url = "https://wagon-dictionary.herokuapp.com/#{answer}"
    json = open(url).read
    JSON.parse(json)['found']
  end

  def make_message(possible, found, answer)
    if possible && found
      "Congratulations! #{answer} is a valid word!"
    elsif !found
      "I'm sorry! #{answer} is not a valid English word."
    elsif !possible
      "Sorry! #{answer} cannot be made with the available letters."
    else
      "Sorry! #{answer} is neither a valid English word nor can it be made from the available letters"
    end
  end

  def score_answer(answer, time)
    score = 0
    split = answer.upcase.split('')
    split.each { |letter| score += 10 / FREQUENCY[letter.to_sym] }
    score *= time
    "Your score is #{score.round}."
  end

  FREQUENCY = {
    E: 12.02,
    T: 9.10,
    A: 8.12,
    O: 7.68,
    I: 7.31,
    N: 6.95,
    S: 6.28,
    R: 6.02,
    H: 5.92,
    D: 4.32,
    L: 3.98,
    U: 2.88,
    C: 2.71,
    M: 2.61,
    F: 2.30,
    Y: 2.11,
    W: 2.09,
    G: 2.03,
    P: 1.82,
    B: 1.49,
    V: 1.11,
    K: 0.69,
    X: 0.17,
    Q: 0.11,
    J: 0.10,
    Z: 0.07
  }
end

require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

before do
  @contents = File.readlines 'data/toc.txt'
end

helpers do
  def in_paragraphs(text)
    paragraphs = text.split("\n\n")
    formatted_paragraphs = paragraphs.map.with_index do |paragraph, index|
      paragraph_number = index + 1
      "<p id=#{paragraph_number}>#{paragraph}</p>"
    end
    formatted_paragraphs.join("\n\n")
  end

  def highlight_match_word(text, word)
    text.gsub(/#{word}/, "<strong>#{word}</strong>")
  end
end

not_found do
  redirect '/'
end

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  erb :home
end

# Create an array of chapters (each element containing the full
# chapter text). Iterate though that array. If query text is
# found in a given chapter, add that chapter number to a results
# array. Return results array.

get '/search' do
  if params['query'] && params['query'] != ''
    @search_string_provided = true
    @query = params['query']
    @matches = []
    @contents.each_with_index do |chapter_title, index|
      chapter_number = (index + 1).to_s
      chapter_link = 'data/chp' + chapter_number + '.txt'
      chapter_text = File.read chapter_link
      if chapter_text =~ /#{@query}/
        matching_paragraphs = retrieve_matching_paragraphs(chapter_text)
        @matches << { chapter_title: chapter_title,
                      chapter_number: chapter_number,
                      matching_paragraphs: matching_paragraphs }
      end
    end
  else
    @search_string_provided = false
  end
  erb :search
end

def retrieve_matching_paragraphs(chapter_text)
  paragraphs = chapter_text.split("\n\n")
  matching_paragraphs = []
  paragraphs.each_with_index do |paragraph, paragraph_number|
    if paragraph =~ /#{@query}/
      matching_paragraphs << { paragraph_number: paragraph_number.to_s,
                               text: paragraph }
    end
  end
  matching_paragraphs
end

get '/chapters/:chapter' do
  number = params['chapter']

  redirect '/' unless number.to_i <= @contents.size

  chapter_path = 'data/chp' + number + '.txt'
  @title = "Chapter #{number}: #{@contents[number.to_i - 1]}"
  @chapter = File.read chapter_path

  erb :chapter
end

get '/show/:name' do
  params['name']
end

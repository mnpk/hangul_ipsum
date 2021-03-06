class HomeController < ApplicationController
  def index
    @text_sources = TextSource.all
  end

  def generate_ipsum
    predicates = Rails.cache.fetch('predicates') {
      Hash[TextSource.all.map{|ts| [ts.id.to_s, ts.predicates]}]
    }
    words = Rails.cache.fetch('words') {
      Hash[TextSource.all.map{|ts| [ts.id.to_s, ts.words]}]
    }
    if params[:text_source_ids]
      predicates = predicates.select{|k,v| params[:text_source_ids].include? k}
      words = words.select{|k,v| params[:text_source_ids].include? k}
    end
    predicates = predicates.values.flatten
    words = words.values.flatten

    paragraphs = unless params[:paragraphs].nil? then params[:paragraphs].to_i else 3 end
    length = params[:length] || 'medium'
    sentence_length = case length
             when 'long'
               10
             when 'medium'
               6
             when 'short'
               3
             end

    p = []
    (1..paragraphs).each do |i|
      s = []
      (1..(sentence_length + rand(3))).each do |j|
        s.push ((words.sample(3 + rand(6)) + [predicates.sample]).join(' '))
      end
      p.push s.join(' ')
    end
    ipsum = p.join('<br><br>')

    data = {:ipsum => ipsum}

    respond_to do |format|
      format.html
      format.json {render :json => data, :callback => params[:callback]}
    end
  end
end

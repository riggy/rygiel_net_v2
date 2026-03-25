class Admin::EmojisController < Admin::BaseController
  def index
    emojis = Emoji.all.each_with_object({}) do |emoji, hash|
      emoji.aliases.each do |name|
        hash[name] = emoji.raw
      end
    end

    render json: emojis
  end
end

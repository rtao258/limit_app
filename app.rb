require "sinatra/base"
require "open3"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    "Disk/File Usage Utility"
  end
  
  def author
    "Raymond Tao"
  end
  
  def color(ratio)
    if ratio < 0.75
      "bg-success"
    elsif 0.75 < ratio && ratio < 0.9
      "bg-warning"
    else
      "bg-danger"
    end
  end

  get "/" do
    redirect to("/xwang")   # default for testing
  end

  get "/:user" do
    @user = params[:user]
    @host = `hostname`
    path = Pathname.new("~jnicklas/home.json")
    file = File.open(path.expand_path, "r")
    quotas = JSON.parse(file.read)["quotas"]
    file.close
    @paths = []
    quotas.each do |hash|
      if hash["user"] == @user
        new_path = {}
        new_path[:path] = Pathname.new(hash["path"]).expand_path
        new_path[:block_usage] = hash["total_block_usage"]
        new_path[:block_limit] = hash["block_limit"]
        new_path[:block_ratio] = new_path[:block_usage]/new_path[:block_limit].to_f
        new_path[:file_usage] = hash["total_file_usage"]
        new_path[:file_limit] = hash["file_limit"]
        new_path[:file_ratio] = new_path[:file_usage]/new_path[:file_limit].to_f
        @paths << new_path
      end
    end
    erb :index
  end
end

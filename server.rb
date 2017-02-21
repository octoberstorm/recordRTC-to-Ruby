require "sinatra"
require "uuid"

get "/" do
  erb :index
end

post "/upload" do
  # uuid = UUID.generate
  video_filename = nil

  puts params.inspect

  ['video', 'audio', 'image'].each do |upload_type|
    blob = "#{upload_type}-blob"

    if params[blob]
      puts "uploads/"
      filename = params["#{upload_type}-filename"]
      upload_dir = "uploads/#{filename}"

      File.open("uploads/#{filename}", "w") do |f|
        f.write(params[blob][:tempfile].read)
      end

      if upload_type == "video"
        video_filename = filename

        mp4_filename = filename.sub(".webm", ".mp4")
        puts "Converting video file..."
        `ffmpeg -i uploads/#{filename} public/video/#{mp4_filename}`
        # `ffmpeg -i public/video/#{filename}.mp4 -i public/video/#{filename}.wav -c:v copy -c:a aac -strict experimental public/video/#{filename}.mp4`
      end

      `mv uploads/#{filename} public/video`
    end
  end

  video_filename
end

get "/video/:filename" do
  @filename = params[:filename] #.to_s.sub(".webm", ".mp4")
  erb :video
end

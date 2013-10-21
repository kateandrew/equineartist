module Gallery
  class << self
    def registered(app)
      app.helpers HelperMethods
    end
    alias :included :registered
  end

  module HelperMethods
    @code = 'main'
    @group_id = {}
    def gallery_sizes(size_code = nil)
      sizes = {
          :thumb => {:width => 180, :height => 135, :crop => false},
          :zoom => {width:1280, :height => 1024, :crop => false}
      }
      size_code ? sizes[size_code] : sizes
    end
    def image_data(file)
      image_data = {}
      gallery_sizes.each do |size_code, size_data|
        image_data[size_code] = uri(file, size_code)
      end
      image_data
    end

    def gallery_data(code)
      data = YAML.load_file(File.join(root, source, 'images', 'gallery.yml'))
      scoped_data = []
      data.each do |item|
        if item['gallery'] == code
          item['image_uris'] = image_data(item['file'])
          scoped_data << item
        end
      end
      scoped_data
    end

    def gallery(code, config = {})
      @group_id ||= {}
      @group_id[code] ||= 0
      config[:template] ||= 'gallery'
      partial 'shared/'+config[:template], :locals => {:code => code.to_s, :group_id => code.to_s+(@group_id[code] += 1).to_s}
    end

    private
    def relative_gallery_path file=nil, size=nil
      path = File.join(images_dir, 'gallery')
      path = size.present? ? File.join(path, size.to_s) : path
      path = file.present? ? File.join(path, file) : path
      path
    end
    def gallery_path file=nil, size=nil
      File.join(root, source, relative_gallery_path(file, size))
    end
    def uri file=nil, size=nil
      resize_image(file, size) if (!File.exists? gallery_path(file, size))
      File.join(relative_gallery_path(file, size)) #@todo: image_url helper
    end
    def resize_image(file, size)
      size_dir = gallery_path(nil, size.to_s)
      FileUtils.mkdir size_dir unless File.exist? size_dir
      image = Magick::Image.read(gallery_path(file)).first
      size_data = gallery_sizes(size)
      newimg = size_data[:crop] ? image.resize_to_fill(size_data[:width], size_data[:height]) : image.resize_to_fit(size_data[:width], size_data[:height])
      newimg.write(gallery_path(file, size)) { self.quality = 90 }
    end
  end

end
::Middleman::Extensions.register(:gallery, Gallery)

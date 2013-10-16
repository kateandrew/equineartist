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
    def gallery_sizes(code = nil)
      sizes = {
          :thumb => {:width => 180, :height => 120, :crop => false},
          :zoom => {width:1280, :height => 1024, :crop => false}
      }
      code ? sizes[code] : sizes
    end
    def image_data(file)
      image_data = {}
      gallery_sizes.each do |size_code, size_data|
        image_data[size_code] = uri(@code, file, size_code)
      end
      image_data
    end

    def gallery_data(code)
      @code = code
      data = YAML.load_file(yaml_path(code))
      data.each do |item|
        item['image_uris'] = image_data(item['file'])
      end
      data
    end

    def gallery(code, config = {})
      @group_id ||= {}
      @group_id[code] ||= 0
      config[:template] ||= 'gallery'
      partial 'shared/'+config[:template], :locals => {:code => code.to_s, :group_id => code.to_s+(@group_id[code] += 1).to_s}
    end

    private
    def relative_gallery_path code, file=nil, size=nil
      path = File.join(images_dir, 'galleries', code)
      path = size.present? ? File.join(path, size.to_s) : path
      path = file.present? ? File.join(path, file) : path
    end
    def gallery_path code, file=nil, size=nil
      File.join(root, source, relative_gallery_path(code, file, size))
    end
    def uri code, file=nil, size=nil
      resize_image(code, file, size) if (!File.exists? gallery_path(code, file, size))
      File.join('/', relative_gallery_path(code, file, size))
    end
    def resize_image(code, file, size)
      size_dir = gallery_path(code, nil, size.to_s)
      FileUtils.mkdir size_dir unless File.exist? size_dir
      image = Magick::Image.read(gallery_path(code, file)).first
      size_data = gallery_sizes(size)
      newimg = size_data[:crop] ? image.resize_to_fill(size_data[:width], size_data[:height]) : image.resize_to_fit(size_data[:width], size_data[:height])
      newimg.write(gallery_path(code, file, size)) { self.quality = 90 }
    end
    def yaml_path code
      gallery_path(code)+'.yml'
    end
  end

end
::Middleman::Extensions.register(:gallery, Gallery)

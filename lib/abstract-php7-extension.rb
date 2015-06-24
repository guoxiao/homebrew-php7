class AbstractPhp7Extension < Formula

  def self.init
    depends_on 'autoconf' => :build
    option 'without-config-file', "Do not install extension config file"
  end

  def safe_phpize
    ENV["PHP_AUTOCONF"] = "#{Formula["autoconf"].opt_bin}/autoconf"
    ENV["PHP_AUTOHEADER"] = "#{Formula["autoconf"].opt_bin}/autoheader"
    system "#{Formula["php7"].opt_bin}/phpize"
  end

  def phpini
    "#{Formula["php7"].config_path}/php.ini"
  end

  def phpconfig
      "--with-php-config=#{Formula["php7"].opt_bin}/php-config"
  end

  def extension
    class_name = self.class.name.split("::").last
    matches = /^Php7(.+)/.match(class_name)
    if matches
      matches[1].downcase
    else
      raise "Unable to guess PHP extension name for #{class_name}"
    end
  end

  def extension_type
    # extension or zend_extension
    "extension"
  end

  def extension
    class_name = self.class.name.split("::").last
    matches = /^Php7(.+)/.match(class_name)
    if matches
      matches[1].downcase
    else
      raise "Unable to guess PHP extension name for #{class_name}"
    end
  end

  def module_path
    opt_prefix / "#{extension}.so"
  end

  def config_file
    begin
      <<-EOS.undent
      [#{extension}]
      #{extension_type}="#{module_path}"
      EOS
    rescue Exception
      nil
    end
  end

  def caveats
    caveats = [ "To finish installing #{extension} for PHP7:" ]

    if build.without? "config-file"
      caveats << "  * Add the following line to #{phpini}:\n"
      caveats << config_file
    else
      caveats << "  * #{config_scandir_path}/#{config_filename} was created,"
      caveats << "    do not forget to remove it upon extension removal."
    end

    caveats << <<-EOS
  * Validate installation via one of the following methods:
  *
  * Using PHP from a webserver:
  * - Restart your webserver.
  * - Write a PHP page that calls "phpinfo();"
  * - Load it in a browser and look for the info on the #{extension} module.
  * - If you see it, you have been successful!
  *
  * Using PHP from the command line:
  * - Run "php -i" (command-line "phpinfo()")
  * - Look for the info on the #{extension} module.
  * - If you see it, you have been successful!
EOS

    caveats.join("\n")
  end

  def config_path
    etc / "php/7"
  end

  def config_scandir_path
    config_path / "conf.d"
  end

  def config_filename
    "ext-" + extension + ".ini"
  end

  def config_filepath
    config_scandir_path / config_filename
  end

  def write_config_file
    if config_filepath.file?
      inreplace config_filepath do |s|
        s.gsub!(/^(;)?(\s*)(zend_)?extension=.+$/, "\\1\\2#{extension_type}=\"#{module_path}\"")
      end
    elsif config_file
      config_scandir_path.mkpath
      config_filepath.write(config_file)
    end
  end
end


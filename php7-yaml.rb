require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Yaml < AbstractPhp7Extension
  init
  homepage "https://pecl.php.net/package/yaml"
  desc "YAML-1.1 parser and emitter"
  head "https://github.com/php/pecl-file_formats-yaml.git", :branch => "php7"

  depends_on "libyaml"

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          "--with-yaml=#{Formula["libyaml"].opt_prefix}",
                          phpconfig
    system "make"
    prefix.install "modules/yaml.so"
    write_config_file if build.with? "config-file"
  end

  test do
    shell_output("#{Formula["php7"].bin}/php -m").include?("yaml")
  end
end

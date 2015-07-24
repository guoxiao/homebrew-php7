require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Mustache < AbstractPhp7Extension
  desc "Mustache PHP Extension"
  init
  homepage "https://github.com/jbboehr/php-mustache"
  head "https://github.com/jbboehr/php-mustache.git", :branch => "php7"

  depends_on "libmustache"

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}", phpconfig
    system "make"
    prefix.install "modules/mustache.so"
    write_config_file if build.with? "config-file"
  end

  test do
    shell_output("#{Formula["php7"].bin}/php -m").include?("mustache")
  end
end

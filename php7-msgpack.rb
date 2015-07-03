require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Msgpack < AbstractPhp7Extension
  init
  homepage "http://pecl.php.net/package/msgpack"
  head "https://github.com/msgpack/msgpack-php.git", :branch => "php7"

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig
    system "make"
    prefix.install "modules/msgpack.so"
    write_config_file if build.with? "config-file"
  end

  test do
    shell_output("#{Formula["php7"].bin}/php -m").include?("msgpack")
  end
end

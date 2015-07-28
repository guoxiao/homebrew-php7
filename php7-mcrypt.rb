require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Mcrypt < AbstractPhp7Extension
  init
  homepage "http://php.net/manual/en/book.mcrypt.php"
  devel do
    url "https://downloads.php.net/~ab/php-7.0.0beta2.tar.xz"
    version "7.0.0beta2"
    sha256 "d17e0b9598592f90c717129cb5b4522223497f86b735bb0b00e53931e03b8ee9"
  end

  depends_on "mcrypt"

  def install
    Dir.chdir "ext/mcrypt"

    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig,
                          "--disable-dependency-tracking",
                          "--with-mcrypt=#{Formula['mcrypt'].opt_prefix}"
    system "make"
    prefix.install "modules/mcrypt.so"
    write_config_file if build.with? "config-file"
  end
end

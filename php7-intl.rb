require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Intl < AbstractPhp7Extension
  desc "PHP Internationalization Extension"
  init
  homepage "http://php.net/manual/en/book.intl.php"
  devel do
    url "https://downloads.php.net/~ab/php-7.0.0beta2.tar.xz"
    version "7.0.0beta2"
    sha256 "d17e0b9598592f90c717129cb5b4522223497f86b735bb0b00e53931e03b8ee9"
  end

  depends_on "icu4c"

  def install
    Dir.chdir "ext/intl"

    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig,
                          "--enable-intl",
                          "--with-icu-dir=#{Formula["icu4c"].prefix}"
    system "make"
    prefix.install "modules/intl.so"
    write_config_file if build.with? "config-file"
  end

  def config_file
    super + <<-EOS.undent

      ;intl.default_locale =
      ; This directive allows you to produce PHP errors when some error
      ; happens within intl functions. The value is the level of the error produced.
      ; Default is 0, which does not produce any errors.
      ;intl.error_level = E_WARNING
    EOS
  end

  test do
    shell_output("#{Formula["php7"].bin}/php -m").include?("intl")
  end
end

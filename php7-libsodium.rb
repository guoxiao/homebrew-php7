require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Libsodium < AbstractPhp7Extension
  init
  desc "PHP extension for libsodium"
  homepage "https://github.com/jedisct1/libsodium-php"
  url "https://github.com/jedisct1/libsodium-php/archive/0.1.3.tar.gz"
  sha256 "cf7314420f270eeef207add6f44c3bdd88b6c6395402d14b9d37ce2171bca734"

  depends_on "libsodium"
  patch do
    url "https://github.com/jedisct1/libsodium-php/pull/23.diff"
    sha256 "7437f3d0ccc52dc19e414bb126ed33d869be31dd1ae44933443329b3318eb4c4"
  end

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}", phpconfig
    system "make"
    prefix.install "modules/libsodium.so"
    write_config_file if build.with? "config-file"
  end

  test do
    shell_output("#{Formula["php7"].bin}/php -m").include?("libsodium")
  end
end

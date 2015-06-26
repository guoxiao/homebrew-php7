require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Mcrypt < AbstractPhp7Extension
  init
  homepage "http://php.net/manual/en/book.mcrypt.php"
  devel do
    url "https://downloads.php.net/~ab/php-7.0.0alpha2.tar.xz"
    version "7.0.0alpha2"
    sha256 "0c16c3f3e488edbddf1de4b1d5b2758e7f5805705bed84cbe9410631be3efd4d"
  end

  bottle do
    root_url "https://homebrew.bintray.com/bottles-php"
    sha256 "07609694adb1377336019ef21d08ffba2451283623fb5898256bc56c72690fc5" => :yosemite
    sha256 "a50a7ed26a8e815d2886da7984bb117db5de86a92c7ca05ecf74374327b96a81" => :mavericks
    sha256 "2b7b8bf256e6024d954e96b6089d63b61c5ef4e9207a9ce1d4ef9a552d4afa72" => :mountain_lion
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

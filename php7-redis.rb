require File.expand_path("../lib/abstract-php7-extension", __FILE__)

class Php7Redis < AbstractPhp7Extension
  init
  desc "PHP redis extension"
  homepage "https://github.com/phpredis/phpredis"
  head "https://github.com/edtechd/phpredis.git", :branch => "php7"

  def install
    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig
    system "make"
    prefix.install "modules/redis.so"
    write_config_file if build.with? "config-file"
  end

  def config_file
    super + <<-EOS.undent

      ; phpredis can be used to store PHP sessions.
      ; To do this, uncomment and configure below
      ;session.save_handler = redis
      ;session.save_path = "tcp://host1:6379?weight=1, tcp://host2:6379?weight=2&timeout=2.5, tcp://host3:6379?weight=2"
    EOS
  end

  test do
    shell_output("#{Formula["php7"].opt_bin}/php -m").include?("redis")
  end
end

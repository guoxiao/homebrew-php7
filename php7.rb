class Php7 < Formula
  desc "PHP 7.0.0beta"
  homepage "https://php.net/"
  skip_clean "bin", "sbin"

  devel do
    url "https://downloads.php.net/~ab/php-7.0.0beta1.tar.xz"
    version "7.0.0beta1"
    sha256 "1d4a768af5c11122fdc6d3417ef08a98302c3abb943ee704282ce1d92537195e"
  end

  option "with-cgi", "Enable building of the CGI executable (implies --without-fpm)"
  option "with-debug", "Compile with debugging symbols"
  option "with-homebrew-curl", "Include Curl support via Homebrew"
  option "with-homebrew-libxslt", "Include LibXSLT support via Homebrew"
  option "with-homebrew-libxml2", "Include Libxml2 support via Homebrew"
  option "with-imap", "Include IMAP extension"
  option "with-libmysql", "Include (old-style) libmysql support instead of mysqlnd"
  option "with-mssql", "Include MSSQL-DB support"
  option "with-pdo-oci", "Include Oracle databases (requries ORACLE_HOME be set)"
  option "with-phpdbg", "Enable building of the phpdbg SAPI executable (PHP 5.4 and above)"
  option "with-snmp", "Build with SNMP support"
  option "with-thread-safety", "Build with thread safety"
  option "with-tidy", "Include Tidy support"
  option "without-bz2", "Build without bz2 support"
  option "without-fpm", "Disable building of the fpm SAPI executable"
  option "without-ldap", "Build without LDAP support"
  option "without-mysql", "Remove MySQL/MariaDB support"
  option "without-pcntl", "Build without Process Control support"
  option "without-pear", "Build without PEAR"

  depends_on "curl" if build.with?("homebrew-curl") || MacOS.version < :lion
  depends_on "enchant" => :optional
  depends_on "freetds" if build.with?("mssql")
  depends_on "freetype"
  depends_on "gettext"
  depends_on "gmp" => :optional
  depends_on "tidy-html5" if build.with?("tidy")
  depends_on "homebrew/dupes/zlib"
  depends_on "icu4c"
  depends_on "imap-uw" if build.with?("imap")
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libxml2" if build.with?("homebrew-libxml2") || MacOS.version < :lion
  depends_on "openssl"
  depends_on "unixodbc"

  deprecated_option "with-pgsql" => "with-postgresql"
  depends_on :postgresql => :optional

  # Sanity Checks
  if build.with?("cgi") && build.with?("fpm")
    raise "Cannot specify more than one CGI executable to build."
  end

  def config_path
    etc+"php"+php_version
  end

  def home_path
    File.expand_path("~")
  end

  def build_fpm?
    !(build.without?("fpm") || build.with?("cgi"))
  end

  def php_version
    "7"
  end

  def php_version_path
    "7"
  end

  def default_config
    "./php.ini-development"
  end

  def skip_pear_config_set?
    build.without? "pear"
  end

  def install_args
    args = [
      "--prefix=#{prefix}",
      "--localstatedir=#{var}",
      "--sysconfdir=#{config_path}",
      "--with-config-file-path=#{config_path}",
      "--with-config-file-scan-dir=#{config_path}/conf.d",
      "--mandir=#{man}",
      "--enable-bcmath",
      "--enable-calendar",
      "--enable-dba",
      "--enable-exif",
      "--enable-ftp",
      "--enable-gd-native-ttf",
      "--enable-mbregex",
      "--enable-mbstring",
      "--enable-shmop",
      "--enable-soap",
      "--enable-sockets",
      "--enable-sysvmsg",
      "--enable-sysvsem",
      "--enable-sysvshm",
      "--enable-wddx",
      "--enable-zip",
      "--enable-intl",
      "--with-freetype-dir=#{Formula["freetype"].opt_prefix}",
      "--with-gd",
      "--with-gettext=#{Formula["gettext"].opt_prefix}",
      "--with-iconv-dir=/usr",
      "--with-icu-dir=#{Formula["icu4c"].opt_prefix}",
      "--with-jpeg-dir=#{Formula["jpeg"].opt_prefix}",
      "--with-kerberos=/usr",
      "--with-libedit",
      "--with-mhash",
      "--with-ndbm=/usr",
      "--with-openssl=" + Formula["openssl"].opt_prefix.to_s,
      "--with-pdo-odbc=unixODBC,#{Formula["unixodbc"].opt_prefix}",
      "--with-png-dir=#{Formula["libpng"].opt_prefix}",
      "--with-unixODBC=#{Formula["unixodbc"].opt_prefix}",
      "--with-xmlrpc",
      "--with-zlib=#{Formula["zlib"].opt_prefix}",
    ]

    if build.with?("homebrew-libxml2") || MacOS.version < :lion
      args << "--with-libxml-dir=#{Formula["libxml2"].opt_prefix}"
    end

    args << "--libexecdir=#{libexec}"

    if build.with? "bz2"
      args << "--with-bz2=/usr"
    end

    if build.with? "debug"
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    if build.with? "enchant"
      args << "--with-enchant=#{Formula["enchant"].opt_prefix}"
    end

    # Build PHP-FPM by default
    if build_fpm?
      args << "--enable-fpm"
      args << "--with-fpm-user=_www"
      args << "--with-fpm-group=_www"
      (prefix+"var/log").mkpath
      touch prefix+"var/log/php-fpm.log"
      plist_path.write plist
      plist_path.chmod 0644
    elsif build.with? "cgi"
      args << "--enable-cgi"
    end

    if build.with? "gmp"
      args << "--with-gmp=#{Formula["gmp"].opt_prefix}"
    end

    if build.with?("homebrew-curl") || MacOS.version < :lion
      args << "--with-curl=#{Formula["curl"].opt_prefix}"
    else
      args << "--with-curl"
    end

    if build.with? "homebrew-libxslt"
      args << "--with-xsl=" + Formula["libxslt"].opt_prefix.to_s
    else
      args << "--with-xsl=/usr"
    end

    if build.with? "imap"
      args << "--with-imap=#{Formula["imap-uw"].opt_prefix}"
      args << "--with-imap-ssl=" + Formula["openssl"].opt_prefix.to_s
    end

    if build.with? "ldap"
      args << "--with-ldap"
      args << "--with-ldap-sasl=/usr"
    end

    if build.with? "libmysql"
      args << "--with-mysql-sock=/tmp/mysql.sock"
      args << "--with-mysqli=#{HOMEBREW_PREFIX}/bin/mysql_config"
      args << "--with-mysql=#{HOMEBREW_PREFIX}"
      args << "--with-pdo-mysql=#{HOMEBREW_PREFIX}"
    elsif build.with? "mysql"
      args << "--with-mysql-sock=/tmp/mysql.sock"
      args << "--with-mysqli=mysqlnd"
      args << "--with-mysql=mysqlnd"
      args << "--with-pdo-mysql=mysqlnd"
    end

    if build.with? "mssql"
      args << "--with-mssql=#{Formula["freetds"].opt_prefix}"
      args << "--with-pdo-dblib=#{Formula["freetds"].opt_prefix}"
    end

    if build.with? "pcntl"
      args << "--enable-pcntl"
    end

    if build.with? "pdo-oci"
      if ENV.key?("ORACLE_HOME")
        args << "--with-pdo-oci=#{ENV["ORACLE_HOME"]}"
      else
        raise "Environmental variable ORACLE_HOME must be set to use --with-pdo-oci option."
      end
    end

    if build.without? "pear"
      args << "--without-pear"
    end

    if build.with? "postgresql"
      if Formula["postgresql"].opt_prefix.directory?
        args << "--with-pgsql=#{Formula["postgresql"].opt_prefix}"
        args << "--with-pdo-pgsql=#{Formula["postgresql"].opt_prefix}"
      else
        args << "--with-pgsql=#{`pg_config --includedir`}"
        args << "--with-pdo-pgsql=#{`which pg_config`}"
      end
    end

    if build.with? "phpdbg"
      args << "--enable-phpdbg"
    end

    if build.with? "tidy"
      args << "--with-tidy=#{Formula["tidy-html5"].opt_prefix}"
    end

    if build.with? "snmp"
      if MacOS.version >= :yosemite
        raise "Please omit \"--with-snmp\" on Yosemite.  See issue #1311 (http://git.io/NBAOvA) for details."
      end

      args << "--with-snmp=/usr"
    end

    if build.with? "thread-safety"
      args << "--enable-maintainer-zts"
    end

    args
  end

  def install
    # Not removing all pear.conf and .pearrc files from PHP path results in
    # the PHP configure not properly setting the pear binary to be installed
    config_pear = "#{config_path}/pear.conf"
    user_pear = "#{home_path}/pear.conf"
    config_pearrc = "#{config_path}/.pearrc"
    user_pearrc = "#{home_path}/.pearrc"
    if File.exist?(config_pear) || File.exist?(user_pear) || File.exist?(config_pearrc) || File.exist?(user_pearrc)
      opoo "Backing up all known pear.conf and .pearrc files"
      opoo <<-INFO
If you have a pre-existing pear install outside
         of homebrew-php, or you are using a non-standard
         pear.conf location, installation may fail.
INFO
      mv(config_pear, "#{config_pear}-backup") if File.exist? config_pear
      mv(user_pear, "#{user_pear}-backup") if File.exist? user_pear
      mv(config_pearrc, "#{config_pearrc}-backup") if File.exist? config_pearrc
      mv(user_pearrc, "#{user_pearrc}-backup") if File.exist? user_pearrc
    end

    begin
      _install
      rm_f("#{config_pear}-backup") if File.exist? "#{config_pear}-backup"
      rm_f("#{user_pear}-backup") if File.exist? "#{user_pear}-backup"
      rm_f("#{config_pearrc}-backup") if File.exist? "#{config_pearrc}-backup"
      rm_f("#{user_pearrc}-backup") if File.exist? "#{user_pearrc}-backup"
    rescue
      mv("#{config_pear}-backup", config_pear) if File.exist? "#{config_pear}-backup"
      mv("#{user_pear}-backup", user_pear) if File.exist? "#{user_pear}-backup"
      mv("#{config_pearrc}-backup", config_pearrc) if File.exist? "#{config_pearrc}-backup"
      mv("#{user_pearrc}-backup", user_pearrc) if File.exist? "#{user_pearrc}-backup"
      raise
    end
  end

  def _install
    system "./configure", *install_args

    system "make", "install"

    # Prefer relative symlink instead of absolute for relocatable bottles
    ln_s "phar.phar", bin+"phar", :force => true if File.exist? bin+"phar.phar"

    # Install new php.ini unless one exists
    config_path.install default_config => "php.ini" unless File.exist? config_path+"php.ini"

    system bin+"pear", "config-set", "php_ini", config_path+"php.ini", "system" unless skip_pear_config_set?

    if build_fpm?
      if File.exist?("sapi/fpm/init.d.php-fpm")
        chmod 0755, "sapi/fpm/init.d.php-fpm"
        sbin.install "sapi/fpm/init.d.php-fpm" => "php#{php_version_path}-fpm"
      end

      if File.exist?("sapi/cgi/fpm/php-fpm")
        chmod 0755, "sapi/cgi/fpm/php-fpm"
        sbin.install "sapi/cgi/fpm/php-fpm" => "php#{php_version_path}-fpm"
      end

      unless File.exist?(config_path+"php-fpm.conf")
        if File.exist?("sapi/fpm/php-fpm.conf")
          config_path.install "sapi/fpm/php-fpm.conf"
        end

        if File.exist?("sapi/cgi/fpm/php-fpm.conf")
          config_path.install "sapi/cgi/fpm/php-fpm.conf"
        end

        inreplace config_path+"php-fpm.conf" do |s|
          s.sub!(/^;?daemonize\s*=.+$/, "daemonize = no")
          s.sub!(/^include\s*=.+$/, ";include=#{config_path}/fpm.d/*.conf")
        end

        inreplace config_path+"www.conf" do |s|
          s.sub!(/^;?listen\.mode\s*=.+$/, "listen.mode = 0666")
          s.sub!(/^;?pm\.max_children\s*=.+$/, "pm.max_children = 10")
          s.sub!(/^;?pm\.start_servers\s*=.+$/, "pm.start_servers = 3")
          s.sub!(/^;?pm\.min_spare_servers\s*=.+$/, "pm.min_spare_servers = 2")
          s.sub!(/^;?pm\.max_spare_servers\s*=.+$/, "pm.max_spare_servers = 5")
        end
      end
    end
  end


  def plist; <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/php-fpm</string>
        <string>--fpm-config</string>
        <string>#{config_path}/php-fpm.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>LaunchOnlyOnce</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
      <key>StandardErrorPath</key>
      <string>#{opt_prefix}/var/log/php-fpm.log</string>
    </dict>
    </plist>
    EOPLIST
  end

  test do
    system "#{bin}/php", "-i"

    if build_fpm?
      system "#{sbin}/php-fpm", "-y", "#{config_path}/php-fpm.conf", "-t"
    end
  end
end

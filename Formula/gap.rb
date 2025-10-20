class Gap < Formula
  desc "System for computational discrete algebra"
  homepage "https://www.gap-system.org/"
  url "https://github.com/gap-system/gap/releases/download/v4.15.1/gap-4.15.1.tar.gz"
  sha256 "6049d53e99b12e25c2d848db21ac4a06380a46fe4c4157243d556fe06930042c"
  license "GPL-2.0-or-later"

  depends_on "gmp"
  # GAP cannot be built against the native macOS version of readline
  # it requires either GNU readline, or no readline at all; but
  # the latter leads to an inferior user experience.
  # So we depend on GNU readline here.
  depends_on "readline"

  # for packages
  depends_on "cddlib"   # CddInterface
  depends_on "curl"     # curlInterface
  depends_on "fplll"    # float
  depends_on "libmpc"   # float
  depends_on "mpfi"     # float
  depends_on "mpfr"     # float, normalizinterface
  depends_on "ncurses"  # browse
  depends_on "pari"     # alnuth
  depends_on "singular" # many packages
  depends_on "zeromq"   # ZeroMQInterface


  def install
    system "./configure", *std_configure_args
    system "make", "install"

    ohai "Building included packages. Please be patient, it may take a while"

    system "mkdir", "-p", "#{lib}/gap/"
    system "cp", "-R", "pkg", "#{lib}/gap/pkg"

    cd lib/"gap/pkg" do
      # NOTE: This script will build most of the packages that require
      # compilation. It is known to produce a number of warnings and
      # error messages, possibly failing to build several packages.
      system buildpath/"bin/BuildPackages.sh", "--with-gaproot=#{lib}/gap"
    end
  end

  test do
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "#{libexec}/tst/testinstall.g"
  end
end

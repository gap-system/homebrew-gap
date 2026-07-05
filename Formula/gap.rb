class Gap < Formula
  desc "System for computational discrete algebra"
  # homepage "https://www.gap-system.org/" - too slow for test-bot
  homepage "https://github.com/gap-system/gap"
  url "https://github.com/gap-system/gap/releases/download/v4.16.0/gap-4.16.0.tar.gz"
  sha256 "aaa296b32a5d7bf25fd80f241d23ec1f58b74e991ae730fafe40e54eb3af6e7e"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-gap/releases/download/gap-4.15.1"
    rebuild 3
    sha256 arm64_tahoe:  "e0e67f712a02b159e1c264f17f825d03fd1ab3cb1ce16ba38d9557e227abd86e"
    sha256 x86_64_linux: "6c7f75a276f24eab2f6135733ed06169079197500aec23445b8bde71dfd91b3f"
  end

  # for some of the packages, e.g. simpcomp
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  # most dependencies are for for packages; only gmp and readline are for GAP itself
  depends_on "cddlib"   # CddInterface
  depends_on "curl"     # curlInterface
  depends_on "flint"    # a 2nd order dep.
  depends_on "fplll"    # float
  depends_on "gmp"      # - for main GAP
  depends_on "libmpc"   # float
  depends_on "mpfi"     # float
  depends_on "mpfr"     # float, normalizinterface
  depends_on "nauty"    # grape
  depends_on "ncurses"  # browse
  depends_on "pari"     # alnuth
  # GAP cannot be built against the native macOS version of readline
  # it requires either GNU readline, or no readline at all; but
  # the latter leads to an inferior user experience.
  # So we depend on GNU readline here.
  depends_on "readline" # - for main GAP
  depends_on "singular" # many packages
  depends_on "libx11"   # for xgap
  depends_on "xorgproto" # for xgap
  depends_on "zeromq"   # ZeroMQInterface

  on_linux do
    depends_on "zlib-ng-compat" # a 2nd order dep.
  end

  def install
    system "./configure", *std_configure_args
    system "make", "install"

    ohai "Building included packages. Please be patient, it may take a while"

    require "fileutils"
    mkdir_p "#{lib}/gap/"
    cp_r "pkg", "#{lib}/gap/pkg"

    cd lib/"gap/pkg" do
      # NOTE: This script will build most of the packages that require
      # compilation. It is known to produce a number of warnings and
      # error messages, possibly failing to build several packages.
      system buildpath/"bin/BuildPackages.sh", "--with-gaproot=#{lib}/gap"
      rm Dir.glob("#{lib}/gap/pkg/**/*.log")
      rm Dir.glob("#{lib}/gap/pkg/**/config.status")
      rm Dir.glob("#{lib}/gap/pkg/**/*.out")
      rm Dir.glob("#{lib}/gap/pkg/**/*.err") # Normalizinterface fails to load  on macOS 26
      rm Dir.glob("#{lib}/gap/pkg/**/Makefile")
      rm Dir.glob("#{lib}/gap/pkg/**/libtool")
    end
  end

  test do
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "#{lib}/gap/pkg/alnuth/tst/testinstall.g"
  end
end

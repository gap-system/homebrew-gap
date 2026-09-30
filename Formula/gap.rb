class Gap < Formula
  desc "System for computational discrete algebra"
  # homepage "https://www.gap-system.org/" - too slow for test-bot
  homepage "https://github.com/gap-system/gap"
  url "https://github.com/gap-system/gap/releases/download/v4.16.1/gap-4.16.1.tar.gz"
  sha256 "df7d116f03c426dac24bf7c76ea11416b29c5a48eac12f97811d80ec215f7f69"
  license "GPL-2.0-or-later"

  # for some of the packages, e.g. simpcomp
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  # most dependencies are for for packages; only gmp and readline are for GAP itself
  depends_on "cddlib"     # CddInterface
  depends_on "curl"       # curlInterface
  depends_on "flint"      # a 2nd order dep.
  depends_on "fplll"      # float
  depends_on "gmp"        # - for main GAP
  depends_on "libmpc"     # float
  depends_on "libx11"     # for xgap
  depends_on "mpfi"       # float
  depends_on "mpfr"       # float, normalizinterface
  depends_on "nauty"      # grape
  depends_on "ncurses"    # browse
  depends_on "pari"       # alnuth
  # GAP cannot be built against the native macOS version of readline
  # it requires either GNU readline, or no readline at all; but
  # the latter leads to an inferior user experience.
  # So we depend on GNU readline here.
  depends_on "readline"   # - for main GAP
  depends_on "singular"   # many packages
  depends_on "xorgproto"  # for xgap
  depends_on "zeromq"     # ZeroMQInterface

  on_linux do
    depends_on "zlib-ng-compat" # a 2nd order dep.
  end

  patch :DATA

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
    (testpath/"testinstallalnuth.g").write <<~EOS
      LoadPackage("alnuth");
      x := Indeterminate(Rationals, "x");
      dirs := DirectoriesPackageLibrary( "alnuth", "tst" );
      tests := ["ALNUTH.tst", "userprefs.tst",];
      tests := List(tests, f -> Filename(dirs,f));
      TestDirectory(tests, rec(exitGAP := true));
    EOS
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "testinstallalnuth.g"
  end
end

__END__
diff --git a/bin/BuildPackages.sh b/bin/BuildPackages.sh
index 8a9f641eb..4b00fce79 100755
--- a/bin/BuildPackages.sh
+++ b/bin/BuildPackages.sh
@@ -96,6 +96,7 @@ then
   IFS=$'\n' PACKAGES=($(find . -maxdepth 2 -type f -name PackageInfo.g | sort -f))
   IFS=$old_IFS
   PACKAGES=( "${PACKAGES[@]%/PackageInfo.g}" )
+  PACKAGES=( "${PACKAGES[@]%./browse}" ) # remove Browse from the list
 fi

 notice "Using GAP root $GAPROOT"

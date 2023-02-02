class Gap < Formula
  desc "System for computational discrete algebra"
  homepage "https://www.gap-system.org/"
  url "https://github.com/gap-system/gap/releases/download/v4.12.2/gap-4.12.2.tar.gz"
  sha256 "672308745eb78a222494ee8dd6786edd5bc331456fcc6456ac064bdb28d587a8"

  depends_on "gmp"
  # GAP cannot be built against the native macOS version of readline
  # it requires either GNU readline, or no readline at all; but
  # the latter leads to an inferior user experience.
  # So we depend on GNU readline here.
  depends_on "readline"

  def install
    # XXX:  Currently there is no `install` target in `Makefile`.
    #   According to the manual installation instructions in
    #
    #     https://github.com/gap-system/gap/blob/master/INSTALL.md
    #
    #   the compiled "bundle" is intended to be used "as is," and there is
    #   no instructions for how to remove the source and other unnecessary
    #   files after compilation.  Moreover, the content of the
    #   subdirectories with special names, such as `bin` and `lib`, is not
    #   suitable for merging with the content of the corresponding
    #   subdirectories of `/usr/local`.  The easiest temporary solution seems
    #   to be to drop the compiled bundle into `<prefix>/libexec` and to
    #   create a symlink `<prefix>/bin/gap` to the startup script.
    #   This use of `libexec` seems to contradict Linux Filesystem Hierarchy
    #   Standard, but is recommended in Homebrew's "Formula Cookbook."

    libexec.install Dir["*"]

    # GAP does not support "make install" so it has to be compiled in place

    cd libexec do
      system "./configure", "--with-readline=#{Formula["readline"].opt_prefix}"
      system "make"
    end

    # Create a symlink `bin/gap` from the `gap` binary
    bin.install_symlink libexec/"gap" => "gap"

    ohai "Building included packages. Please be patient, it may take a while"
    cd libexec/"pkg" do
      # NOTE: This script will build most of the packages that require
      # compilation. It is known to produce a number of warnings and
      # error messages, possibly failing to build several packages.
      system "../bin/BuildPackages.sh", "--with-gaproot=#{libexec}"
    end
  end

  test do
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "#{libexec}/tst/testinstall.g"
  end
end

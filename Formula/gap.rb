class Gap < Formula
  desc "System for computational discrete algebra"
  homepage "https://www.gap-system.org/"
  url "https://github.com/gap-system/gap/releases/download/v4.12.2/gap-4.12.2.tar.gz"
  sha256 "672308745eb78a222494ee8dd6786edd5bc331456fcc6456ac064bdb28d587a8"
  license "GPL-2.0-or-later"


  head do
    url "https://github.com/gap-system/gap.git", branch: "master"
    depends_on "autoconf" => :build # required by packages below
  end


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
  depends_on "zeromq"   # ZeroMQInterface
  depends_on "singular" # many packages
  depends_on "pari"     # many packages

  def install


    no_compilation_packages = [
      "atlasrep", "aclib", "agt", "alnuth", "automata", "automgrp",
      "autpgrp", "circle", "classicpres", "congruence", "corelg",
      "crime", "crisp", "cryst", "crystcat", "ctbllib", "cubefree",
      "design", "difsets", "factint", "fga", "fining", "format",
      "forms", "fr", "francy", "fwtree", "gapdoc", "gbnp", "genss",
      "groupoids", "grpconst", "guarana", "hap", "hapcryst", "hecke",
      "help", "idrel", "images", "intpic", "irredsol", "itc",
      "jupyterkernel", "jupyterviz", "kan", "laguna", "liealgdb",
      "liepring", "liering", "loops", "lpres", "majoranaalgebras",
      "mapclass", "matgrp", "modisom", "nilmat", "nock",
      "numericalsgps", "openmath", "packagemanager", "patternclass",
      "permut", "polenta", "polycyclic", "polymaking", "primgrp",
      "qpa", "quagroup", "radiroot", "rcwa", "rds", "recog",
      "repndecomp", "repsn", "resclasses", "scscp", "sglppow",
      "sgpviz", "singular", "sl2reps", "sla", "smallgrp", "smallsemi",
      "sonata", "sophus", "spinsym", "standardff", "symbcompcc",
      "thelma", "tomlib", "toric", "transgrp", "ugaly", "unipot",
      "unitlib", "utils", "uuid", "walrus", "wedderga", "xmod",
      "xmodalg", "yangbaxter",
      # These packages have `doc` and `test` make targets, but we
      # don't actually call them
      "4ti2interface", "autodoc", "cap", "examplesforhomalg",
      "gaussforhomalg", "generalizedmorphismsforcap", "gradedmodules",
      "gradedringforhomalg", "homalg", "homalgtocas", "io_forhomalg",
      "linearalgebraforcap", "localizeringforhomalg",
      "matricesforhomalg", "modulepresentationsforcap", "modules",
      "monoidalcategories", "nconvex", "ringsforhomalg", "sco",
      "toolsforhomalg", "toricvarieties",
    ]

    # These two packages either don't build or don't work
    # "cddinterface", "xgap",
    configure_packages = [
      "anupq", "caratinterface", "crypting", "curlinterface", "cvec",
      "datastructures", "deepthought", "digraphs", "ferret", "float",
      "gauss", "grape", "io", "json", "normalizinterface", "nq",
      "orb", "profiling", "semigroups", "simpcomp", "zeromqinterface",
      ]

    old_configure_packages = [
      "ace", "browse", "cohomolo", "edim", "example", "fplsa",
      "guava", "kbmag",
    ]



    all_packages = no_compilation_packages
                     .concat(configure_packages)
                     .concat(configure_packages)

    # Start actually building GAP
    if build.head?
      system "./autogen.sh"
    end

    libexec.install Dir["pkg"]

    system "./configure", "--prefix", libexec/"gap", "--with-readline=#{Formula["readline"].opt_prefix}"
    if build.head?
      system "make", "bootstrap-pkg-full"
      # system "make", "doc"      # Do we need this?
    end
    system "make", "install"

    # Create a symlink `bin/gap` from the `gap` binary
    bin.install_symlink libexec/"gap/bin/gap" => "gap"

    ohai "Building included packages. Please be patient, it may take a while"
    pkg_dir = "#{libexec}/pkg"

    cd libexec/"pkg" do

      system "mkdir", "#{libexec}/gap/lib/gap/pkg/"

      # The makefiles appear to only be used for docs...
      # The BuildPackages.sh script didn't call them
      all_packages.each do |pkg|
        system "cp", "-R", pkg, "#{libexec}/gap/lib/gap/pkg/"
        cd pkg do
          if File.exist?("./prerequisites.sh")
            system "./prerequisites.sh", "#{libexec}/gap/lib/gap"
          end
        end
      end

      configure_packages.each do |pkg|
        cd pkg do
          system "./configure", "--with-gaproot=#{libexec}/gap/lib/gap"
          system "make"
          system "/usr/bin/rsync", "-aEvL", "bin/", "#{libexec}/gap/lib/gap/pkg/"
        end
      end
      old_configure_packages.each do |pkg|
        cd pkg do
          system "./configure", "#{libexec}/gap/lib/gap"
          system "make"
          system "/usr/bin/rsync", "-aEvL", "bin/", "#{libexec}/gap/lib/gap/pkg/"
        end
      end
    end
  end

  test do
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "#{libexec}/tst/testinstall.g"
  end

end

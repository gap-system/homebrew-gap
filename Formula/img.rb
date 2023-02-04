class Img < Formula
  desc "Iterated monodromy groups in GAP"
  homepage "https://gap-packages.github.io/img/"
  url "https://github.com/gap-packages/img/releases/download/v0.3.0/IMG-0.3.0.tar.gz"
  sha256 "41a59cf49be79b2f617e0e5d1f1e73838e6bd2f1d2ea3f234177a31c33c6826d"
  license "GPL-3"

  depends_on "gap-system/gap/gap"
  depends_on "cmake" => :build
  depends_on "openblas" => :build
  depends_on "suite-sparse" => :build
  
  bottle :unneeded
  
  def install
    system "./configure", "--with-gaproot=#{Formula["gap-system/gap/gap"].opt_prefix}/libexec"
    system "make"
    (share/"gap/pkg/img-0.3.0").install Dir["*"]
  end

  test do
    (testpath/"test1.g").write <<~EOF
OnBreak:=function() Print("FATAL ERROR"); FORCE_QUIT_GAP(1); end;;
LoadPackage("img");
FORCE_QUIT_GAP(0);
EOF
    system Formula["gap-system/gap/gap"].opt_prefix/"bin/gap", "test1.g"
  end
end

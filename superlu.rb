require "formula"

class Superlu < Formula
  homepage "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/"
  url "http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_4.3.tar.gz"
  sha1 "d2863610d8c545d250ffd020b8e74dc667d7cbdd"
  revision 1

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/science"
    cellar :any
    sha1 "40705cde7208ea9b6f3b51c1a6dc260a49188f29" => :yosemite
    sha1 "a36d71883305da75d38d77754e336d345043e1d3" => :mavericks
    sha1 "8f0e4afa6f901f5345ff25658cfb7c2c84ef818e" => :mountain_lion
  end

  option "without-check", "skip build-time tests (not recommended)"

  depends_on :fortran
  depends_on 'openblas' => :optional

  def install
    ENV.deparallelize
    cp "MAKE_INC/make.mac-x", "./make.inc"
    make_args = ["RANLIB=true", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}",
                 "FORTRAN=#{ENV.fc}", "FFLAGS=#{ENV.fcflags}",
                 "SuperLUroot=#{buildpath}",
                 "SUPERLULIB=$(SuperLUroot)/lib/libsuperlu.a"]

    make_args << ((build.with? "openblas") ? "BLASLIB=-L#{Formula["openblas"].opt_lib} -lopenblas" : "BLASLIB=-framework Accelerate")

    system "make", "lib", *make_args
    if build.with? "check"
      system "make", "testing", *make_args
      cd "TESTING"
      system "make", *make_args
      %w[stest dtest ctest ztest].each do |tst|
        ohai `tail -1 #{tst}.out`.chomp
      end
      cd ".."
    end
    prefix.install "make.inc"
    File.open(prefix / "make_args.txt", "w") do |f|
      f.puts(make_args.join(" "))  # Record options passed to make.
    end
    lib.install Dir["lib/*"]
    (include / "superlu").install Dir["SRC/*.h"]
    doc.install Dir["Doc/*"]
    (share / "superlu").install "EXAMPLE"
  end
end

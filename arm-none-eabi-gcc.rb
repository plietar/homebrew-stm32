require 'formula'

class ArmNoneEabiGcc < Formula
  homepage 'http://www.gnu.org/software/gcc/gcc.html'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.1/gcc-4.9.1.tar.bz2'
  sha1 '3f303f403053f0ce79530dae832811ecef91197e'

  # http://sourceware.org/newlib/
  resource 'newlib' do
    url 'ftp://sourceware.org/pub/newlib/newlib-2.1.0.tar.gz'
    sha1 '364d569771866bf55cdbd1f8c4a6fa5c9cf2ef6c'
  end

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'

  depends_on 'arm-none-eabi-binutils'

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  def install
    resource('newlib').stage do
      # Reported and fixed upstream
      # http://comments.gmane.org/gmane.comp.lib.newlib/8879
      Patch.create(:p1, :DATA).apply

      (buildpath).install Dir['newlib', 'libgloss']
    end

    # See https://gcc.gnu.org/ml/gcc/2014-05/msg00014.html
    ENV["CC"]  += " -fbracket-depth=1024"
    ENV["CXX"] += " -fbracket-depth=1024"

    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << 'c++' unless build.include? 'disable-cxx'

    args = [
            "--target=arm-none-eabi",
            "--prefix=#{prefix}",

            "--enable-multilib",
            "--enable-interwork",
            "--enable-languages=#{languages.join(',')}",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--with-ld=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-ld'}",
            "--with-as=#{Formula["arm-none-eabi-binutils"].opt_bin/'arm-none-eabi-as'}",
            "--with-newlib",
            "--with-headers=newlib/libc/include",

            "--disable-nls",
            "--disable-shared",
            "--disable-threads",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libgomp",
            "--disable-newlib-supplied-syscalls",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
            "--with-cloog=#{Formula["cloog"].opt_prefix}",
            "--with-isl=#{Formula["isl"].opt_prefix}",
            "--with-system-zlib"
    ]

    mkdir 'build' do
      system "../configure", *args
      system "make"

      ENV.deparallelize
      system "make install"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree
  end
end

__END__
diff --git a/libgloss/arm/configure b/libgloss/arm/configure
index cc7e570..bdd4b13 100644
--- a/libgloss/arm/configure
+++ b/libgloss/arm/configure
@@ -2551,7 +2551,7 @@ esac



-host_makefile_frag=${srcdir}/../config/default.mh
+host_makefile_frag=`cd $srcdir/../config;pwd`/default.mh

 host_makefile_frag_path=$host_makefile_frag

diff --git a/libgloss/arm/configure.in b/libgloss/arm/configure.in
index d617f49..f9409ca 100644
--- a/libgloss/arm/configure.in
+++ b/libgloss/arm/configure.in
@@ -59,7 +59,8 @@ esac

 AC_SUBST(objtype)

-host_makefile_frag=${srcdir}/../config/default.mh
+host_makefile_frag=`cd $srcdir/../config;pwd`/default.mh
+

 dnl We have to assign the same value to other variables because autoconf
 dnl doesn't provide a mechanism to substitute a replacement keyword with

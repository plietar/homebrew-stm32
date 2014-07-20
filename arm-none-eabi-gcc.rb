require 'formula'

class ArmNoneEabiGcc < Formula
  homepage 'http://www.gnu.org/software/gcc/gcc.html'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.0/gcc-4.9.0.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.0/gcc-4.9.0.tar.bz2'
  sha1 'fbde8eb49f2b9e6961a870887cf7337d31cd4917'

  # http://sourceware.org/newlib/
  resource 'newlib' do
    url 'ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz'
    sha1 'ea6b5727162453284791869e905f39fb8fab8d3f'
  end

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'

  depends_on 'arm-none-eabi-binutils'

  # Fix build with clang
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?format=multiple&id=60981
  patch :DATA

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  def install
    resource('newlib').stage do
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
diff --git a/lto-plugin/configure b/lto-plugin/configure
index 2fc8383..a579b99 100755
--- a/lto-plugin/configure
+++ b/lto-plugin/configure
@@ -4087,8 +4087,32 @@ fi
   done
 CFLAGS="$save_CFLAGS"
 
+
+# Check whether -static-libgcc is supported.
+saved_LDFLAGS="$LDFLAGS"
+LDFLAGS="$LDFLAGS -static-libgcc"
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for -static-libgcc" >&5
+$as_echo_n "checking for -static-libgcc... " >&6; }
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+  int main() {}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  have_static_libgcc=yes
+else
+  have_static_libgcc=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $have_static_libgcc" >&5
+$as_echo "$have_static_libgcc" >&6; };
+LDFLAGS="$saved_LDFLAGS"
 # Need -Wc to get it through libtool.
-if test "x$GCC" = xyes; then ac_lto_plugin_ldflags="-Wc,-static-libgcc"; fi
+if test "x$have_static_libgcc" = xyes; then
+   ac_lto_plugin_ldflags="-Wc,-static-libgcc"
+fi
+
 
 case `pwd` in
   *\ * | *\  *)
@@ -10562,7 +10586,7 @@ else
   lt_dlunknown=0; lt_dlno_uscore=1; lt_dlneed_uscore=2
   lt_status=$lt_dlunknown
   cat > conftest.$ac_ext <<_LT_EOF
-#line 10565 "configure"
+#line 10589 "configure"
 #include "confdefs.h"
 
 #if HAVE_DLFCN_H
@@ -10668,7 +10692,7 @@ else
   lt_dlunknown=0; lt_dlno_uscore=1; lt_dlneed_uscore=2
   lt_status=$lt_dlunknown
   cat > conftest.$ac_ext <<_LT_EOF
-#line 10671 "configure"
+#line 10695 "configure"
 #include "confdefs.h"
 
 #if HAVE_DLFCN_H
diff --git a/lto-plugin/configure.ac b/lto-plugin/configure.ac
index 4003ae6..a5f1774d 100644
--- a/lto-plugin/configure.ac
+++ b/lto-plugin/configure.ac
@@ -7,9 +7,21 @@ AM_MAINTAINER_MODE
 AC_PROG_CC
 AC_SYS_LARGEFILE
 ACX_PROG_CC_WARNING_OPTS([-Wall], [ac_lto_plugin_warn_cflags])
+
+# Check whether -static-libgcc is supported.
+saved_LDFLAGS="$LDFLAGS"
+LDFLAGS="$LDFLAGS -static-libgcc"
+AC_MSG_CHECKING([for -static-libgcc])
+AC_LINK_IFELSE([
+  int main() {}], [have_static_libgcc=yes], [have_static_libgcc=no])
+AC_MSG_RESULT($have_static_libgcc); 
+LDFLAGS="$saved_LDFLAGS"
 # Need -Wc to get it through libtool.
-if test "x$GCC" = xyes; then ac_lto_plugin_ldflags="-Wc,-static-libgcc"; fi
+if test "x$have_static_libgcc" = xyes; then
+   ac_lto_plugin_ldflags="-Wc,-static-libgcc"
+fi
 AC_SUBST(ac_lto_plugin_ldflags)
+
 AM_PROG_LIBTOOL
 ACX_LT_HOST_FLAGS
 AC_SUBST(target_noncanonical)


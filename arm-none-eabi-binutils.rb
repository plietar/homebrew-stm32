require 'formula'

class ArmNoneEabiBinutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.24.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz'
  sha1 '1b2bc33003f4997d38fadaa276c1f0321329ec56'

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--target=arm-none-eabi",
            "--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--disable-nls",
            "--enable-multilib"]

    mkdir 'build' do
      system "../configure", *args

      system "make"
      system "make install"
    end

    info.rmtree # info files conflict with native binutils
  end
end

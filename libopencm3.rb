require "formula"

class Libopencm3 < Formula
  homepage 'http://libopencm3.org/'
  head 'git://github.com/libopencm3/libopencm3.git'

  depends_on 'arm-none-eabi-gcc'

  def install
    system "make"
    system "make", "DESTDIR=#{prefix}", "install"
  end
end


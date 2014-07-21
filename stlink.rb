require "formula"

class Stlink < Formula
  version '1.0.0'
  homepage 'https://github.com/texane/stlink'
  url 'https://github.com/texane/stlink/archive/1.0.0.tar.gz'
  sha1 'd55bbdd8c4c907be15b28d089fddc86e7a167766'

  head do
    url 'https://github.com/texane/stlink.git'
  end

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libusb' => :build
  depends_on 'pkg-config' => :build

  def install
    system './autogen.sh'
    system "./configure --prefix=#{prefix}"
    system 'make install'
  end

  test do
    system "st-info"
  end
end

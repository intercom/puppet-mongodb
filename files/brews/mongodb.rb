require "formula"

class Mongodb < Formula
  homepage "https://www.mongodb.org/"

  stable do
    url "https://fastdl.mongodb.org/src/mongodb-src-r2.6.8.tar.gz"
    sha1 "d67254ef3ba5ba81e21c56be9b919c3a10e01b32"

    if MacOS.version == :el_capitan
      patch do
        url "https://gist.githubusercontent.com/patrickod/cf8d177c949eaf25e18f/raw/219946186c0ba286e1a6c641c7c5d1f0487f766f/mongodb_el_capitan.diff"
        sha1 "7fe780472930b07f9b0bcb7ed72a6c3682b79a06"
      end
    end
  end

  version '2.6.8-boxen1'

  bottle do
    sha1 "2841ae12013757c67605edd084a94c5a709c5345" => :yosemite
    sha1 "2c5f3f581a322948140af65a51906b15b8b18778" => :mavericks
    sha1 "8aa4750499fdeb325e7fe6d3a72aab186861ca90" => :mountain_lion
  end

  devel do
    url "https://fastdl.mongodb.org/src/mongodb-src-r3.1.1.tar.gz"
    sha1 "a0d9ae6baa6034d5373b3ffe082a8fea5c14774f"
  end

  head "https://github.com/mongodb/mongo.git"

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on "boost" => :optional
  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "openssl" => :optional

  # Review this patch with each release.
  # This modifies the SConstruct file to include 10.10 as an accepted build option.
  if MacOS.version == :yosemite
    patch do
      url "https://raw.githubusercontent.com/DomT4/scripts/fbc0cda/Homebrew_Resources/Mongodb/mongoyosemite.diff"
      sha1 "f4824e93962154aad375eb29527b3137d07f358c"
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
    ]

    # For Yosemite with Clang 3.5+ we need this to build Mongo pre 2.7.7
    # See: https://github.com/mongodb/mongo/pull/956#issuecomment-94545753
    if MacOS.version == :yosemite || MacOS.version == :el_capitan
      args << "--disable-warnings-as-errors"
    end

    # --full installs development headers and client library, not just binaries
    # (only supported pre-2.7)
    args << "--full" if build.stable?
    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var+"mongodb").mkpath
    (var+"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end

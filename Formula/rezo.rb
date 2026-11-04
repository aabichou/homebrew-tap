class Rezo < Formula
  desc "Menu bar monitor for ZLT X31 5G boxes: signal, battery, traffic"
  homepage "https://github.com/aabichou/rezo"
  url "https://github.com/aabichou/rezo/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "a2396421ba292dea71dbb3c1bd62c2fba87041b017c5aab6bd5d33b420147eda"
  license "MIT"

  bottle do
    root_url "https://github.com/aabichou/rezo/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "7510e67d70c3690313e4aba2e5c23cdc740d955df2da2f4f00d137b54d6b06ea"
  end


  depends_on macos: :sonoma

  def install
    cd "Rezo" do
      ENV["VERSION"] = version.to_s
      # SwiftPM's own sandbox can't nest inside Homebrew's build sandbox.
      ENV["SWIFT_BUILD_FLAGS"] = "--disable-sandbox"
      system "./build.sh"
      prefix.install "Rezo.app"
    end
    (bin/"rezo").write <<~SH
      #!/bin/sh
      # `rezo` opens the menu bar app; `rezo --check` prints a diagnostic snapshot.
      if [ "$1" = "--check" ]; then
        exec "#{opt_prefix}/Rezo.app/Contents/MacOS/Rezo" --check
      fi
      exec open "#{opt_prefix}/Rezo.app"
    SH
  end

  service do
    run [opt_prefix/"Rezo.app/Contents/MacOS/Rezo"]
    run_type :immediate
    process_type :interactive
  end

  def caveats
    <<~EOS
      Start Rezo now and at every login:
        brew services start rezo

      Or open it once:
        rezo

      To also find it in Spotlight and Launchpad:
        ln -sf #{opt_prefix}/Rezo.app /Applications/Rezo.app

      If the menu bar icon is missing, a menu bar manager (Ice, Bartender)
      may have hidden it, or it may sit behind the notch.
    EOS
  end

  test do
    app = prefix/"Rezo.app"
    assert_path_exists app/"Contents/MacOS/Rezo"
    assert_equal version.to_s,
      shell_output("/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' #{app}/Contents/Info.plist").strip
  end
end

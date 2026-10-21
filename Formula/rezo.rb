class Rezo < Formula
  desc "Menu bar monitor for ZLT X31 5G boxes: signal, battery, traffic"
  homepage "https://github.com/aabichou/rezo"
  url "https://github.com/aabichou/rezo/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "33040c9f62089662af5ae06d4ec42635720c3067cbacd8e61d5941151f3bbb0c"
  license "MIT"

  bottle do
    root_url "https://github.com/aabichou/rezo/releases/download/v0.1.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "e9826671bb4ec6c42a2e057acc5e51a1fde81893e5ec868513fb729fc2a34e9b"
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

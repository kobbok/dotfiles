#!/bin/bash

# Uncomment for debugging
#set -o xtrace

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
  cat <<EOF
Usage:
     update-preferences         Updates the preferences
     rebind-keys                Rebind keyboard (fixes problem with German keyboard)
     rebind-keys-permanently    Same as rebind-keys but registers a script with launchd for a more permanent fix
     install-homebrew           Attempts to install homebrew
     install-brew-packages      Attempts to install homebrew packages
     -h|--help                  Displays this help
EOF
}

function update_preferences() {
  # To find out what defaults do what its useful to do `defaults read > defaults_before` -> do your changes -> `defaults read > defaults_after` -> `nvim -d defaults_before defaults_after`
  # Do note that some things cannot be changed from defaults, and that restarts of the system may be required to apply the changes
  # Some defaults copied directly from https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh

  # Update some MacOS preferences
  defaults write -globalDomain AppleICUDateFormatStrings '{1="y.MM.dd";}'

  # Faster key repeating (lower is faster)
  defaults write -globalDomain KeyRepeat -int 2

  # Click on where you want to go in scrollbar
  defaults write -globalDomain AppleScrollerPagingBehavior -bool true

  # Txt Input > Correct spelling automatically
  defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Txt Input > Capitalise words automatically
  defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

  # Txt Input > Add full stop with double-space
  defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Show bluetooth indicator on control center
  defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true

  # Auto hide dock
  defaults write com.apple.dock "autohide" -bool true

  # Show seconds on clock
  defaults write com.apple.menuextra.clock "ShowSeconds" -bool true

  ################################################################################
  # Finder > Preferences
  ################################################################################

  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show wraning before changing an extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Show wraning before removing from iCloud Drive
  defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

  # Finder > View > As List
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Finder > View > Show Path Bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Settings > Trackpad > More Gestures > Swipe between pages > off
  defaults write -globalDomain AppleEnableSwipeNavigateWithScrolls -bool false

  # Settings > Trackpad > More Gestures > Notification Center > toggle off
  defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

  # Hidden
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  for app in "Dock" "Finder"; do
    killall "${app}" >/dev/null 2>&1
  done

  echo "Preferences updated, a logout/restart may be required"
  # Look into https://github.com/smudge/nightlight for automating this
  echo "Remember to turn on night shift (System Preferences => Displays => Night Shift... => Schedule = Sunset to Sunrise) as it can't be modified from scripts"
}

# DESC: Rebind for german keyboard
# ARGS: $@ (optional): Wether the change should be permanent (creates a file)
# OUTS: None
function rebind_keyboard() {
  local make_permanent=0
  for i in "$@"; do
    echo "Found argument $i"
    if [[ $i == "permanent" ]]; then
      make_permanent=1
    fi
  done
  # https://apps.apple.com/tr/app/key-codes/id414568915 may be useful if this breaks or orther keys need to be remapped
  # Remap for current session
  hidutil property --set '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc":0x700000035, "HIDKeyboardModifierMappingDst":0x700000064}, {"HIDKeyboardModifierMappingSrc":0x700000064, "HIDKeyboardModifierMappingDst":0x700000035}] }'
  # The following can be added after "property" to affect only certain keyboards
  # <string>--matching</string>
  # <string>{"ProductID":0x343}</string>
  if [[ make_permanent -eq 1 ]]; then
    echo "Permanent rebind script is broken execute commands yourself"
    exit 1
    # Remap permanently
    echo "Making remap permanent"
    # The folder LaunchAgents may not exist
    sudo echo '<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
		<dict>
		    <key>Label</key>
		    <string>com.user.keyboard-remap-login-script</string>
		    <key>ProgramArguments</key>
		    <array>
			<string>/usr/bin/hidutil</string>
			<string>property</string>
			<string>--set</string>
			<string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035, "HIDKeyboardModifierMappingDst":0x700000064}, {"HIDKeyboardModifierMappingSrc":0x700000064, "HIDKeyboardModifierMappingDst":0x700000035}]}</string>
		    </array>
		    <key>RunAtLoad</key>
		    <true/>
		</dict>
		</plist>' >/Library/LaunchDaemons/com.user.keyboard-remap-login-script.plist
    # You may need to do launchctl unload first
    sudo launchctl load -w -- /Library/LaunchDaemons/com.user.keyboard-remap-login-script.plist
  fi
}

function install_homebrew() {
  # Install homebrew
  /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (
    echo
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  ) >>/Users/martin/.zprofile
}

function install_packages() {
  # Optionally install oh-my-zsh
  #sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  brew tap nats-io/nats-tools
  brew install -q firefox neovim discord obsidian thunderbird syncthing \
    bruno inkscape \
    python3 node lazygit jq nmap websocat \
    colima docker docker-compose \
    cmake ninja dfu-util ccache clang-format \
    android-platform-tools \
    7zip \
    nats-io/nats-tools/nats \
    kitty \
    fd ripgrep ast-grep \
    font-fira-code-nerd-font \
    rust
  brew services start syncthing
  echo "Syncthing started, connect it to everything by opening 127.0.0.1:8384 in a browser"
  # Rosetta is usually required
  #/usr/sbin/softwareupdate --install-rosetta --agree-to-license
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
    -h | --help)
      script_usage
      exit 0
      ;;
    update-preferences)
      update_preferences
      ;;
    rebind-keys)
      rebind_keyboard
      ;;
    rebind-keys-permanently)
      rebind_keyboard permanent
      ;;
    install-homebrew)
      install_homebrew
      ;;
    install-brew-packages)
      install_packages
      ;;
    *)
      echo "Invalid parameter was provided: $param"
      script_usage
      exit 1
      ;;
    esac
  done
}

function main() {
  parse_params "$@"
}

if ! (return 0 2>/dev/null); then
  main "$@"
fi

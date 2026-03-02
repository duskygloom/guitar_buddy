#!/usr/bin/bash

echo "1. Copy application to $HOME/.local/lib/guitar_buddy"
cp -R "../build/linux/x64/release/bundle" "$HOME/.local/lib/guitar_buddy"

echo "2. Install desktop file to $HOME/.local/share/applications"
desktop-file-install --dir="$HOME/.local/share/applications" "guitar_buddy.desktop"
update-desktop-database "$HOME/.local/share/applications"

echo "3. Copy icons to /usr/share/icons/hicolor"
sudo cp "../assets/ic_launcher/res/mipmap-mdpi/ic_launcher.png" "/usr/share/icons/hicolor/48x48/apps/app.duskygloom.guitar_buddy.png"
sudo cp "../assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png" "/usr/share/icons/hicolor/192x192/apps/app.duskygloom.guitar_buddy.png"

echo "4. Update icons"
sudo gtk-update-icon-cache "/usr/share/icons/hicolor"
sudo gtk4-update-icon-cache "/usr/share/icons/hicolor"

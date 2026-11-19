# Margem

Comments you pin to any spot in any app on your Mac, with Claude or ChatGPT answering right there.

This repository only holds Margem's release files. The app's source is private.

## Install

In Terminal:

```sh
curl -fsSL https://github.com/gabrielmouallem/margem-releases/releases/latest/download/install.sh | sh
```

The script downloads `Margem.zip` from the latest release, checks its SHA-256 and its signature, puts Margem in Applications and opens it. Nothing else. Read it first: it is `install.sh` in each release.

Margem is not notarized by Apple yet, so a copy downloaded in a browser is stopped the first time you open it. Allow it in System Settings › Privacy & Security › Open Anyway, or run `xattr -dr com.apple.quarantine /Applications/Margem.app`.

Needs macOS 14 or later on a Mac with Apple silicon. Free for 14 days, then $19 once.

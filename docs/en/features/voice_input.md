# Voice input (dictation)

Most devices can turn speech into text, so people can speak instead of typing. This is called dictation or voice typing. It is useful for people who find typing slow or difficult, and for anyone who prefers to speak when writing a proposal, a debate or a comment.

Consul Democracy does not include any speech recognition of its own. It does not record, receive or store audio. Dictation is provided by the operating system (or, on Linux, by a separate application) and the result is inserted into the text field as if it had been typed.

To let users know about this option, the description field of the forms to create proposals, debates, budget investments and collaborative legislation proposals shows a short hint: "You can dictate using your device's voice typing." You can change the text of the hint as explained in [Translations and texts](../customization/translations.md) (the identifier is `shared.voice_input_hint`).

This page explains how to use the dictation built into each operating system. You can share these steps with your users, or link to this page from your own help pages.

## Overview

| Device | Tool | How to start |
| --- | --- | --- |
| Windows 10 and 11 | Voice typing (built in) | Press the Windows key + H |
| macOS | Dictation (built in) | Use the Dictation shortcut, or Edit > Start Dictation |
| Linux | Handy (separate free application) | Press the shortcut you choose in Handy |
| Android | Voice typing in Gboard (the Google keyboard) | Tap the microphone icon on the keyboard |
| iPhone and iPad | Dictation (built in) | Tap the microphone key on the keyboard |

## Before you start

* Click or tap inside the text field where you want to write. Dictated text is inserted where the cursor is.
* You need a working microphone. Phones and most laptops have one built in.
* Your device may ask for permission to use the microphone the first time. The permission is requested by your device, not by Consul Democracy.
* Not every language is supported by every device. If your language is not available, use the keyboard instead.
* Depending on the device and the language, your speech may be processed on your device or sent to the provider of the dictation service (Microsoft, Apple, Google). Check the privacy information of your device if this matters to you.
* Always read the text after dictating. Speech recognition can make mistakes, especially with names, technical terms and noisy surroundings.

## Windows

Windows 11 calls this feature _voice typing_ and Windows 10 calls it _dictation_. The shortcut is the same in both. Voice typing needs an internet connection.

### Turn on and use voice typing

1. Click inside the text field where you want to write.
2. Press the **Windows** key + **H** on your keyboard. On a touch screen, press the microphone button on the touch keyboard instead.
3. A small voice typing bar appears. Wait until it shows "Listening..." and then start speaking.
4. To stop, press the **Windows** key + **H** again, click the microphone button on the bar, or say "Stop listening".

You can say the names of punctuation marks, such as "comma", "period" or "question mark", to add them to the text.

### Dictate in another language

1. Open **Start > Settings > Time & language > Language & region**.
2. Under **Preferred languages**, select **Add a language**, choose your language and select **Next**.
3. Select **Next** (or **Install**) to finish adding the language.
4. Press the **Windows** key + **Spacebar** and choose that language.
5. Press the **Windows** key + **H** and speak in that language.

### If it does not work

* Make sure the cursor is inside a text field. Voice typing only starts when there is somewhere to write.
* Open **Start > Settings > Privacy & security > Microphone** and check that microphone access is on.
* Open **Start > Settings > System > Sound > Input** and check that the right microphone is selected.
* If Voice access is already running, it takes over from voice typing. Select the text field and start speaking, or turn Voice access off.

More information: [Use voice typing to talk instead of type on your PC (Microsoft Support)](https://support.microsoft.com/en-us/accessibility/windows/use-voice-typing-to-talk-instead-of-type-on-your-pc).

## macOS

On a Mac, the feature is called _Dictation_. It has to be turned on once.

### Turn on Dictation

1. Choose **Apple menu > System Settings**.
2. Click **Keyboard** in the sidebar. You may need to scroll down.
3. Find **Dictation**, turn it on and click **Enable** if asked.
4. If your Mac asks whether to share audio recordings to improve Siri and Dictation, choose the option you prefer. You can change this later in **System Settings > Privacy & Security > Analytics & Improvements**.
5. Optional: in the same **Dictation** section, open the **Shortcut** menu and choose the shortcut you want to use to start Dictation.

### Use Dictation

1. Click inside the text field where you want to write.
2. Start Dictation with your Dictation shortcut, with the Microphone key on your keyboard (if it has one), or by choosing **Edit > Start Dictation** from the menu bar.
3. Speak. Say "new line" or "new paragraph" to start a new line, and say the names of punctuation marks, such as "exclamation mark", to add them.
4. To stop, press the **Esc** key, the Microphone key or your Dictation shortcut. Dictation also stops by itself after 30 seconds without speech.

### Other settings

* **Language:** in **System Settings > Keyboard > Dictation**, click **Edit** next to **Languages** to add or remove a language. With several languages, click the language indicator next to the cursor (or press the Globe key) to switch.
* **Microphone:** use the **Microphone source** menu in the same section to choose the microphone.
* **Privacy:** the text below the Dictation setting tells you whether your speech is processed on your Mac or sent to Apple.

If **Voice Control** is turned on, it replaces standard Dictation. Turn Voice Control off to use the steps above.

More information: [Dictate messages and documents on Mac (Apple Support)](https://support.apple.com/en-ie/guide/mac-help/mh40584/26/mac).

## Linux

Linux does not have a built-in dictation feature that works in every desktop and every browser. A free option is [Handy](https://handy.computer), an open source application that turns speech into text in any text field. Handy is a separate project and is not maintained by Consul Democracy. It runs speech recognition on your own computer, so your voice is not sent to a cloud service. Handy also works on Windows and macOS.

The steps below are a summary. For the latest instructions, see the [Handy project page](https://github.com/cjpais/handy).

### Install Handy

1. Go to [handy.computer](https://handy.computer) or the [Handy releases page](https://github.com/cjpais/handy/releases) and download the latest version for Linux.
2. Install it:
   * On Debian and Ubuntu, install the `.deb` file with APT so that dependencies are installed too, for example `sudo apt install ./Handy_*.deb`.
   * On other distributions, use the AppImage from the releases page.
3. If Handy does not start and reports a missing `libgtk-layer-shell.so.0` library, install it:

```bash
# Debian and Ubuntu
sudo apt install libgtk-layer-shell0
# Fedora
sudo dnf install gtk-layer-shell
# Arch Linux
sudo pacman -S gtk-layer-shell
```

### Install a text-input tool

Handy needs a small helper tool to type the text into other applications. Install the one for your display server. If you are not sure which one you use, run `echo $XDG_SESSION_TYPE`.

| Display server | Tool | Command |
| --- | --- | --- |
| X11 | xdotool | `sudo apt install xdotool` |
| Wayland | wtype (preferred) | `sudo apt install wtype` |
| Wayland or X11 | dotool (alternative) | `sudo apt install dotool`, then `sudo usermod -aG input $USER` and log out and back in |

On Ubuntu 26.04 with Wayland, `wtype` does not work. Handy's documentation recommends `ydotool` instead; follow the instructions on the Handy project page.

### Set up Handy

1. Start Handy and allow the microphone (and accessibility) permissions if asked.
2. Open **Settings > Models** and choose a speech recognition model. The first time, Handy downloads the model, which can be large. Smaller models are faster and use less memory; larger models are usually more accurate.
3. Open the shortcut settings and choose a keyboard shortcut. Handy can work as _push-to-talk_ (hold the shortcut while speaking, release to stop) or as a toggle (press once to start and once to stop).
4. On Wayland, global shortcuts have to be set in your desktop environment. Create a custom shortcut that runs the command `handy --toggle-transcription`:
   * **GNOME:** **Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts**.
   * **KDE Plasma:** **System Settings > Shortcuts > Custom Shortcuts**.

### Use Handy

1. Click inside the text field where you want to write. It can be in any application, including your web browser.
2. Press your shortcut (and keep it pressed if you use push-to-talk) and speak.
3. Stop recording. After a moment, Handy inserts the transcribed text into the field.

### If it does not work

* Check that you installed the text-input tool for your display server (see above).
* If text does not appear in the right place, open **Settings > Advanced** in Handy and set **Overlay Position** to **None**.
* If Handy shows a blank window or closes at startup, see the "Known issues" section of the Handy project page.

## Android

Most Android phones use Gboard, the Google keyboard, which has a built-in microphone for voice typing. If your phone uses another keyboard (for example the Samsung keyboard), look for a microphone key on that keyboard; the steps are similar.

### Turn on voice typing

1. Install **Gboard** from the Google Play Store if your phone does not have it yet.
2. Open **Settings > System > Languages & input > On-screen keyboard** and make sure Gboard is the active keyboard. The names of these menus vary between phones.
3. Open the Gboard settings, select **Voice typing** and turn on voice typing.

### Use voice typing

1. Tap the text field where you want to write, so that the keyboard appears.
2. Tap the **microphone** icon at the top of the keyboard.
3. The first time, Android asks for permission to record audio. Choose **While using the app** (or **Only this time**). Voice typing cannot work without microphone access.
4. Speak when the keyboard shows that it is listening.
5. To stop, tap the microphone icon again. To go back to the normal keyboard, tap the keyboard icon.

You can say punctuation such as "comma", "period", "question mark", "new line" or "new paragraph". Punctuation commands are not available in all languages. To correct a word, touch and hold it, tap the microphone and say the new word.

### Dictate in another language

1. Add the language in **Gboard settings > Languages**.
2. When voice typing is active, tap the language abbreviation at the bottom left of the voice toolbar and choose a language.

On some Pixel phones, voice typing is called _Advanced voice typing_ or _Assistant voice typing_ and works slightly differently. The basic steps are the same.

More information: [Type with your voice (Gboard Help)](https://support.google.com/gboard/answer/2781851).

## iPhone and iPad

On iPhone and iPad, the feature is called _Dictation_. It has to be turned on once.

### Turn on Dictation

1. Open **Settings > General > Keyboard**.
2. Turn on **Enable Dictation**. If a message appears, tap **Enable Dictation** again.

### Use Dictation

1. Tap the text field where you want to write, so that the keyboard appears.
2. Tap the **microphone** key on the keyboard. The first time, tap **OK** or **Allow** if iOS asks for permission to use the microphone.
3. Speak. iOS adds punctuation automatically and you can also say it, such as "comma" or "question mark". You can keep using the keyboard while dictating.
4. To stop, tap the microphone key or the keyboard key again.

### If you cannot see the microphone key

* Check that **Enable Dictation** is turned on in **Settings > General > Keyboard**.
* Check that Dictation is not blocked in **Settings > Screen Time > Content & Privacy Restrictions**.
* Some third-party keyboards do not have a microphone key. Switch to the Apple keyboard with the globe key.
* On an iPad with an external keyboard, the on-screen keyboard is hidden. Use the dictation key of your keyboard, if it has one.
* Dictation is not available in every language and region. On supported models and languages it also works without an internet connection.

More information: [Dictate text on iPhone (Apple Support)](https://support.apple.com/guide/iphone/dictate-text-iph2c0651d2/ios).

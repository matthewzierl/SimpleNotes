# SimpleNotes

I attempted to recreate the Notes app from Apple using only UIKit. This was a challenge
project assigned by Paul Hudson in 100 Days of Swift that I decided to add more features
and bring to the next level.
<p align="center">
  <img src="https://github.com/user-attachments/assets/247fb788-04cb-4d83-bff0-0ea6283109d9" width="200">
  <img src="https://github.com/user-attachments/assets/be49aa20-59ba-46c7-92ba-87526912d011" width="200">
</p>

## Features I Implemented 🛠️
- **Multiple Viewing Options** - ViewController's view depends on whether user choose 'Gallery' or 'List'
- **Secure Notes** - Lock sensitive notes with Face ID/Touch ID.
<p>
  <img src="https://github.com/user-attachments/assets/fa6e7051-8d93-4e42-8e80-fa6d5111a554" width="150">
  <img src="https://github.com/user-attachments/assets/f42aeb09-ad02-436d-9fe7-ab8a6f18a4b6" width="150">
</p>

- **Sharing Notes** - UIAcitivtyViewController to share notes to other apps/people.
<p>
  <img src="https://github.com/user-attachments/assets/278440c6-a860-4eba-8b1b-716f3318468a" width="150">
</p>

- **Organized Structure** - Categorize and sort notes by dates created/edited.
- **Saving Notes** - I used User Defaults (probably shouldn't have😳) to save notes.
- **Insert Image** - Notes are now more visually appealing with the option to import photos.
- **Selection Overlays** - Added subview to CollectionView to highlight notes selected.
<p>
  <img src="https://github.com/user-attachments/assets/9ccb9f10-ed7b-4d38-abeb-326294395d48" width="150">
  <img src="https://github.com/user-attachments/assets/46cb0f4d-a0b3-4323-82cd-ddb8a44aca9a" width="150">
</p>

## Bugs I Plan To Fix 🐞

- **CollectionView Section Header** - The headers overlap with cell titles which makes for annoying user experience.
- **Images Don't Save** - I suspect it has something to do with UserDefaults, or maybe I have to save photos as 'Data'.

## Features I Would Like to Implement 🤤
- **Text Formatting** - Right now, users cannot create bullit points or change font size.
- **Different Method of Saving** - I know how to use SwiftData in SwiftUI, but not sure if I can use it with UIKit.

<div align="center">

# 📱 Mobile App Development
### Week 1 · Foundations: Theory, Setup & Dart

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)

*Understand the why, build the environment, practice the language.*

</div>

---

## 🧭 At a Glance

| | Part | What I did | Link |
|:-:|---|---|---|
| 📖 | **Theory** | Researched native vs cross-platform, Flutter, hybrid tools, UI/UX | [Overview.md](Overview.md) |
| 🛠️ | **Setup** | Installed Flutter SDK + Android Studio, verified with `flutter doctor` | [SetUp.md](SetUp.md) |
| 🌾 | **Project 1** | Big Farm Management System in Dart | [Farm_Management.md](Farm_Management.md) |
| 🪐 | **Project 2** | Universe Observer System in Dart | [Universe_Observer.md](Universe_Observer.md) |

---

## 📖 Theory in 60 Seconds

| Approach | Idea | Trade-off |
|---|---|---|
| 🍎🤖 **Native** | Swift/Kotlin, one codebase per OS | Best performance, double the work |
| 🔁 **Cross-platform** | One codebase for both OSes (Flutter, React Native) | Faster and cheaper, small performance cost |
| 🌐 **Hybrid** | Web app in a WebView (Ionic, Cordova) | Easy for web devs, slowest of the three |

💡 **Flutter** draws its own pixels (Skia/Impeller), **Dart** is its language.
🎨 **UX** is how it works. **UI** is how it looks.

---

## 🛠️ Setup Checklist

- [x] Flutter SDK in `C:\src\flutter`
- [x] `bin` folder added to system Path
- [x] Android Studio + SDK Command-line Tools
- [x] Licenses accepted (`flutter doctor --android-licenses`)
- [x] `flutter doctor` all green ✅

<div align="center">
<img src="images1/set_up.png" alt="flutter doctor" width="48%">
<img src="images1/hellodart.png" alt="Hello Dart" width="48%">
</div>

---

## 💻 Dart Practice Projects

<table>
<tr>
<td width="50%" align="center">

### 🌾 Big Farm Management
Animals, plants, feeding, harvests, market value

`LivingBeing → Animal → Poultry → Chicken`

[📄 Read the docs](Farm_Management.md)

<img src="images1/farm_management.png" alt="Farm" width="100%">

</td>
<td width="50%" align="center">

### 🪐 Universe Observer
Galaxies, stars, planets, telescopes

`CelestialObject → Planet → RockyPlanet`

[📄 Read the docs](Universe_Observer.md)

<img src="images1/universe_observer.png" alt="Universe" width="100%">

</td>
</tr>
</table>

---

## 🧩 Dart Concepts Covered

`Variables` · `Control flow` · `Functions` · `Classes & Enums` · `Inheritance` · `Mixins` · `Interfaces` · `Async / Streams` · `Exceptions` · `Null safety` · `Generics` · `Records` · `Pattern matching` · `Extensions`

---

## ▶️ Run It

Paste a `.dart` file into **[DartPad](https://dartpad.dev)** and press **Run**, or locally:

```bash
dart run farm_management.dart
dart run universe_observer.dart
```

---

<div align="center">

**Next up:** first Flutter app 🚀 widgets · layouts · navigation · state

</div>
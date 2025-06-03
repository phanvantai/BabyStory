# 📖 Baby Story App – Subscription & AI Model Plan

## 🎯 Goal

Implement a freemium model that offers value to free users and unlocks premium features for paying users.

---

## 🔓 Free Plan

- ✅ Up to **3 AI-generated stories per day**
- ✅ Uses **GPT-3.5 Turbo** (default model)
- 🚫 Cannot choose AI model
- 🚫 No voice narration (text-to-speech)
- 🚫 No custom story settings (theme, length, etc.)
- 🚫 Only supports **one profile**

> Ideal for discovery and casual daily use.

---

## 🔐 Premium Plan (Subscription)

- ✅ Up to **10 stories per day**
- ✅ Can choose from **multiple AI models**:
  - GPT-4o (creative, expressive)
  - Claude Sonnet (gentle, warm)
  - [Optional: Gemini or other models]
- ✅ **Voice mode** (text-to-speech playback)
- ✅ **Open custom create story settings**
- ✅ **Multiple baby profiles**

> Designed for engaged parents who want more control and value.

---

## ⚙️ Model Selection Behavior

- Free users can **see** model selection UI but it's **locked**
  - Display badge: _“Premium only”_
  - Tooltip: _“Upgrade to choose different story styles”_
- Premium users can freely choose a model per story

---

## 📊 Story Usage Limit

- Display a usage meter in UI:
  - “2 / 3 stories used today”
- When users reach the daily limit, soft upsell:
  - _“Upgrade to enjoy more stories today!”_

---

## 🧠 Model Info Tooltip (Optional)

- **GPT-3.5 Turbo**: Fast, simple storytelling (Free)
- **GPT-4o**: Rich, imaginative, emotionally expressive
- **Claude Sonnet**: Gentle tone, nurturing story style
- _(Add more descriptions if supporting other models)_

---

## ✅ Next Steps

- [x] Implement `StoryGenerationConfig` model ✅ **COMPLETED**
- [ ] Add story usage tracking logic  
  - [ ] Persist `StoryGenerationConfig` to local storage (`UserDefaults`)
  - [ ] Load it on app startup and inject into the story generation flow
  - [ ] On story creation:
    - [ ] Call `resetDailyCountIfNeeded()`
    - [ ] Check `canGenerateNewStory` before proceeding
    - [ ] If valid, call `incrementStoryCount()`
    - [ ] Save the updated config after changes
  - [ ] If over limit, show paywall or upsell
  - [ ] Optionally: log usage events via analytics

- [ ] Lock model selector in UI for free users  
  - [ ] Disable selection or show premium badge for locked models
  - [ ] Auto-select `gpt-3.5-turbo` if user is free tier

- [ ] Design and show upsell when story limit is hit  
  - [ ] Detect when `canGenerateNewStory == false`
  - [ ] Show modal or full-screen paywall with messaging

- [ ] Add paywall screen with benefits list  
  - [ ] Compare Free vs Premium features
  - [ ] Monthly / yearly subscription CTA
  - [ ] Explain access to model options, voice mode, extra daily stories

- [ ] Add voice mode (text-to-speech) for premium users  
  - [ ] Use `AVSpeechSynthesizer` or 3rd-party API
  - [ ] Lock access behind premium check
  - [ ] Add playback UI to story viewer


# 🤖 The "Vibe Coded" Manifesto & Disclaimer

> [!NOTE]
> This is not a distro, just my personal config that based on someone's config

Let's address the elephant in the room: **Yes, this configuration is heavily driven by AI—what some might call "Vibe Coding."** 

But before you dismiss this as just another bloated, hallucinated spaghetti-code config, hear me out. This is "Vibe Coding" done with extreme prejudice and rigorous engineering standards. 

Here is exactly how my Neovim config was forged:

## 🧠 The Dual-Engine AI Core
This config was built utilizing the bleeding edge of LLMs, specifically **Gemini 3.1 Pro** and **Claude Sonnet 4.6 Extended**. I didn't just ask them to "write a config"; I used them as pair-programming compilers.

## ⚙️ The Forging Process
*   **5+ Rounds of Interrogation:** No lua file was merged on the first try. Every piece of code goes through at least 5 deep review cycles. I always start with raw functionality, but the later rounds are strictly dedicated to **memory control, garbage collection (GC), and extreme performance optimization**.
*   **AI Cross-Validation (The Crucible):** I regularly take the output from Gemini and feed it to Claude, and vice versa. I make them critique each other's code to eliminate blind spots until I reach the most optimized solution.
*   **Zero "Spaghetti" Tolerance:** To prevent context degradation and the dreaded accumulation of spaghetti code, I constantly start **fresh chats**. Clean context equals clean code. Rumors also said that AI are more clever when in a new chat.
*   **RTFM (Read The F***ing Manual):** I never rely on the AI's outdated training data. I constantly feed them the latest Neovim documentation such as NeoVim news (leader pN)and the raw source code of existing plugins, alongside my own strict feedback and architectural directions.

## ⚡ The Engineering Mandate
My strict prompt to the AIs was to **squeeze every last drop out of Neovim 0.12+ APIs**. 
*   I heavily utilize `libuv` for background tasks.
*   Everything that can be asynchronous, *is* asynchronous.
*   I bypass slow Lua wrappers and directly invoke native **C-level APIs** whenever possible.
*   **DIY & Snacks First:** Instead of installing a new plugin for every minor feature, I forced the AIs to hand-roll functionalities from scratch. If I absolutely needed a Swiss Army knife, I used `snacks.nvim` to handle it.

## 🗣️ A Note on the Chinese Comments
You will notice a lot of Mandarin comments scattered throughout the Lua files. Two reasons for this:
1. I am simply too lazy to translate or delete them.
2. Chinese characters are incredibly efficient for **saving prompt tokens** when feeding context back to the LLMs. Consider it a feature of the workflow! ฅ(ᵔ꒳ ᵔマ.ᐟ

## 🛡️ Daily Driver Status
I actually use this. I have completely uninstalled VSCode and Zed. This is my exclusive daily driver, and it handles everything flawlessly—from standard project development to safely editing core system files.

---

## ⚠️ STRICT LIABILITY WARNING FOR PRODUCTION
Although this is my stable daily driver, but please **DO NOT blindly deploy this config in strict, mission-critical production environments.** 

Because this pushes the boundaries of Neovim nightly (0.12+) and relies on highly customized, hand-rolled asynchronous C-API calls, edge cases *will* exist. I take **zero liability** for any unrecoverable errors, data loss, or downtime that might occur in a corporate/production setting. Use it, learn some from it, but **use it at your own risk.**

---

## 🐛 Feedback & Issues
If you are brave enough to try this and you spot a bug, a memory leak, or have ideas to push the optimization even further—**please open an Issue!** Let's make this AI-forged rice even faster.

---

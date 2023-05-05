/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import LLM.GPT.Chat
import LLM.gpt4all
import LLM.llama_cpp

/-!
# Obtain the preferred chat bot.
-/

namespace LLM

/-- Help text when no chat bot is available. -/
def noChatBotMessage : String := "Could not find a usable chat bot!

You can try one of the following:
" ++ OpenAI_instructions ++ gpt4all_instructions ++ llama_cpp_instructions

/--
Find an available chat bot, preferring in order:
* `gpt-4` or `gpt-3.5-turbo` (OpenAI's ChatGPT APIs)
* `ggml-gpt4all-j-v1.3-groovy.bin` (the GPT4All-J commerically licensable model)
* `7B/ggml-model-q4_0.bin` (the 4-bit quantised version of the 7B LLaMA model)
-/
def findChatBot : IO ChatBot := do
  try
    discard <| GPT.OPENAI_API_KEY
    return ChatGPT
  catch _ => try
    discard <| findModel "ggml-gpt4all-j-v1.3-groovy.bin" []
    gpt4all "ggml-gpt4all-j-v1.3-groovy.bin"
  catch _ => match ← IO.getEnv "LLAMA_CPP_HOME" with
  | some p => do try
      discard <| findModel "7B/ggml-model-q4_0.bin" [p / "models"]
      llama_cpp "7B/ggml-model-q4_0.bin"
    catch _ => throw <| IO.userError noChatBotMessage
  | none => throw <| IO.userError noChatBotMessage


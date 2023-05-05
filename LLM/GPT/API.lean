/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import LLM.IO.runCmd

/-!
# Minimal interface to the ChatGPT API, without any parsing.

See `LLM.GPT.Json` for parsing.
-/

namespace LLM.GPT

/-- Retrieve the API key from the OPENAI_API_KEY environment variable. -/
def OPENAI_API_KEY : IO String := do match (← IO.getEnv "OPENAI_API_KEY") with
  | none => throw $ IO.userError "No API key found in environment variable OPENAI_API_KEY"
  | some k => pure k

/-- Send a JSON message to the OpenAI chat endpoint, and return the response. -/
def chat (msg : String) (trace : Bool := false) : IO String := do
  if trace then IO.println msg
  let r ← runCmd "curl"
      #["https://api.openai.com/v1/chat/completions", "-H", "Content-Type: application/json",
        "-H", "Authorization: Bearer " ++ (← OPENAI_API_KEY), "--data-binary", "@-"] false msg
  if trace then IO.print r
  return r

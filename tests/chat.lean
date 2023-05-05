import LLM.FindChatBot

open LLM

-- These tests are commented out as they should not be run in CI.

-- #eval do IO.println (← ChatGPT.sendMessages [
--   ⟨.system, "You are a helpful chatbot."⟩,
--   ⟨.user, "Hello, my name is Edith."⟩,
--   ⟨.assistant, "Hi Edith! My name is Dave."⟩,
--   ⟨.user, "What's my name?"⟩] )

-- -- Your name is Edith. How can I help you today?

-- #eval do IO.println (← (← gpt4all).sendMessages [
--   ⟨.system, "You are a helpful chatbot."⟩,
--   ⟨.user, "Hello, my name is Edith."⟩,
--   ⟨.assistant, "Hi Edith! My name is Dave."⟩,
--   ⟨.user, "What's my name?"⟩] )

-- -- Dave.

-- #eval do IO.println (← (← llama_cpp).sendMessages [
--   ⟨.system, "You are a helpful chatbot."⟩,
--   ⟨.user, "Hello, my name is Edith."⟩,
--   ⟨.assistant, "Hi Edith! My name is Dave."⟩,
--   ⟨.user, "What's my name?"⟩] )

-- -- Dave
-- --
-- -- \section{Example 2}

-- #eval do IO.println (← (← findChatBot).sendMessages [
--   ⟨.system, "Transcript of a dialog, where the User interacts with an Assistant.
-- The assistant is helpful, kind, honest, good at writing,
-- and never fails to answer the User's requests immediately and with precision."⟩,
--   ⟨.user, "Hello!"⟩,
--   ⟨.assistant, "Hello. How may I help you today?"⟩,
--   ⟨.user, "Please tell me the largest city in Europe."⟩,
--   ⟨.assistant, "Sure. The largest city in Europe is Moscow, the capital of Russia."⟩,
--   ⟨.user, "What is the capital of France?"⟩])

-- Typical output from GPT4:
-- * The capital of France is Paris.

-- Typical output from `7B/ggml-model-q4_0.bin`:
-- * Paris, but there are many more cities in France.

-- Typical output from `ggml-gpt4all-j-v1.3-groovy.bin`:
-- * Paris is the capital of France.

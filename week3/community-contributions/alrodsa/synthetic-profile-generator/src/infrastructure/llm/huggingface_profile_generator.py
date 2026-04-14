import json
import re

import torch
from huggingface_hub import login
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, pipeline

from src.domain.entities.profile import Profile
from src.domain.services.profile_generator import ProfileGenerator

DEFAULT_QUANT_CONFIG = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_quant_type="nf4",
)


class HuggingFaceProfileGenerator(ProfileGenerator):

    def __init__(
        self,
        model_name: str,
        hf_token: str,
        max_new_tokens: int = 2048,
        quantization_config: BitsAndBytesConfig | None = DEFAULT_QUANT_CONFIG,
    ):
        if not hf_token:
            raise ValueError(
                "HuggingFace token is required. Set the HF_TOKEN environment variable."
            )
        login(hf_token, add_to_git_credential=True)

        self._model_name = model_name
        self._max_new_tokens = max_new_tokens

        tokenizer = AutoTokenizer.from_pretrained(model_name)
        tokenizer.pad_token = tokenizer.eos_token
        self._tokenizer = tokenizer

        model_kwargs = {"device_map": "auto"}
        if quantization_config is not None:
            model_kwargs["quantization_config"] = quantization_config

        model = AutoModelForCausalLM.from_pretrained(model_name, **model_kwargs)

        self._pipe = pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            max_new_tokens=max_new_tokens,
        )

    def generate(self, num_profiles: int) -> list[Profile]:
        messages = [{"role": "user", "content": self._build_prompt(num_profiles)}]
        prompt = self._tokenizer.apply_chat_template(
            messages, tokenize=False, add_generation_prompt=True,
        )
        response = self._pipe(prompt, do_sample=True, temperature=0.7)
        raw_text = response[0]["generated_text"]
        data = self._extract_json(raw_text)
        return [Profile(**item) for item in data]

    def _build_prompt(self, num_profiles: int) -> str:
        return (
            f"Generate exactly {num_profiles} synthetic user profiles.\n\n"
            "Return ONLY a valid JSON array. No explanation, no markdown.\n\n"
            "Each profile must have these fields:\n"
            '- "name": string (realistic fictional full name)\n'
            '- "age": integer between 18 and 80\n'
            '- "country": string\n'
            '- "city": string (real city in that country)\n'
            '- "occupation": string\n'
            '- "email": string (unique, realistic, @example.com)\n'
            '- "interests": array of 3 to 5 strings\n'
            '- "bio": string (1-2 sentences)\n'
            '- "source_type": "synthetic"\n\n'
            "Rules:\n"
            "- All emails must be unique\n"
            "- Data must be realistic but entirely fictional\n"
            "- Return ONLY the JSON array, nothing else\n"
        )

    def _extract_json(self, text: str) -> list[dict]:
        match = re.search(r"\[.*\]", text, re.DOTALL)
        if not match:
            raise ValueError("No JSON array found in LLM response")

        return json.loads(match.group())

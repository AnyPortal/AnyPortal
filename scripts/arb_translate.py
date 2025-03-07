# %%
import json
import os
import subprocess
from typing import Any
import glob

# Configure your LLM and target languages
MODEL = "mistral"
ARB_DIR = "lib/l10n"
REFERENCE_LANG = "en"  # Base language file

LANG_FILES = glob.glob(f"*.arb", root_dir=ARB_DIR)
TARGET_LANGS = [LANG_FILE[4:-4] for LANG_FILE in LANG_FILES]
print(TARGET_LANGS)

# %%
def format_arb(jsonObj: dict[str, Any]):
    file_meta = {}
    main_keys = {}
    meta_keys = {}

    # Categorize keys
    for key, value in jsonObj.items():
        if key.startswith("@@"):
            file_meta[key] = value  # File-level metadata
        elif key.startswith("@"):
            meta_keys[key] = value  # Regular metadata
        else:
            main_keys[key] = value  # Regular translation keys

    # Sort keys
    sorted_keys = sorted(main_keys.keys())

    # Reconstruct JSON
    formatted_data = {**file_meta}  # Start with file metadata
    for key in sorted_keys:
        formatted_data[key] = main_keys[key]
        meta_key = f"@{key}"
        if meta_key in meta_keys:
            formatted_data[meta_key] = meta_keys[meta_key]

    # Write back to file
    return formatted_data


# Load reference file
with open(os.path.join(ARB_DIR, f"app_{REFERENCE_LANG}.arb"), encoding="utf-8") as f:
    base_data = json.load(f)

with open(
    os.path.join(ARB_DIR, f"app_{REFERENCE_LANG}.arb"), "w", encoding="utf-8"
) as f:
    json.dump(format_arb(base_data), f, ensure_ascii=False, indent=2)


def translate_text(text, target_lang):
    prompt = f"Translate the following to {target_lang}: {text}"
    result = subprocess.run(
        ["ollama", "run", MODEL, prompt], capture_output=True, text=True
    )
    return result.stdout.strip()


# Translate and update each target ARB file
for lang in TARGET_LANGS:
    arb_path = os.path.join(ARB_DIR, f"app_{lang}.arb")

    # Load existing translations or create new file
    if os.path.exists(arb_path):
        with open(arb_path, encoding="utf-8") as f:
            translated_data = json.load(f)
    else:
        translated_data = {}

    # Translate missing keys
    for key, value in base_data.items():
        key: str
        if key.startswith("@"):
            translated_data[key] = value
        elif (
            key not in translated_data
            or not translated_data[key]
            or translated_data[key] is None
        ):
            translated_data[key] = None
            # translated_data[key] = translate_text(value, lang)

    translated_data["@@locale"] = lang

    # Save updated translations
    with open(arb_path, "w", encoding="utf-8") as f:
        json.dump(format_arb(translated_data), f, ensure_ascii=False, indent=2)

    print(f"Translated {lang} ARB file updated!")

# %%

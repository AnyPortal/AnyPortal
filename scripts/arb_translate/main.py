# %%
import json
import os
import subprocess
from typing import Any
import glob

# Configure your LLM and target languages
MODEL = "deepseek-r1:70b"
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

# update each target ARB file
for lang in TARGET_LANGS:
    arb_path = os.path.join(ARB_DIR, f"app_{lang}.arb")

    # Load existing translations or create new file
    if os.path.exists(arb_path):
        with open(arb_path, encoding="utf-8") as f:
            translated_data = json.load(f)
    else:
        translated_data = {}
    
    cnt = 0
    for key, value in base_data.items():
        key: str
        if key == "@@locale":
            translated_data[key] = lang
        elif key.startswith("@"):
            translated_data[key] = value
        elif (
            key not in translated_data
            or not translated_data[key]
            or translated_data[key] is None
        ):
            translated_data[key] = None
            cnt += 1

    translated_data["@@locale"] = lang

    # Save updated translations
    with open(arb_path, "w", encoding="utf-8") as f:
        json.dump(format_arb(translated_data), f, ensure_ascii=False, indent=2)

    print(f"{lang}: null keys: {cnt}")


# %%
from openai import OpenAI
import httpx
import json
from scripts.arb_translate.extract_json import extract_json
from scripts.arb_translate.config import *

client = OpenAI(
    base_url=OPENAI_BASE_URL,
    api_key='ollama',
    http_client=httpx.Client(proxy=HTTP_CLIENT_PROXY)
)

# %%
with open(os.path.join(ARB_DIR, f"app_{REFERENCE_LANG}.arb"), encoding="utf-8") as f:
    arb_en_str = f.read()

arb_en_dict = json.loads(arb_en_str)

def get_arb_lang_str(lang):
    arb_path = os.path.join(ARB_DIR, f"app_{lang}.arb")
    assert os.path.exists(arb_path)
    with open(arb_path, encoding="utf-8") as f:
        return f.read()

def get_missing_keys(base_data, translated_data):
    keys = set()
    for key, value in base_data.items():
        key: str
        if key.startswith("@"):
            continue
        elif (
            key not in translated_data
            or not translated_data[key]
            or translated_data[key] is None
        ):
            keys.add(key)
    return keys

def get_prompt_messages(lang, arb_en_str, arb_lang_str, arb_missing_str):
    return [
        {"role": "system", "content": "The user will provide with arb files which need translation. One file will be in English, another file in a different language where some of the keys may have already been translated which you can use as a reference, and the final file showing you keys you need to translate. Answer with only the newly translated items."},
        {"role": "user", "content": 
f"""English arb:
```
{arb_en_str}
```

partially translated arb:
```
{arb_lang_str}
```

arb in English that needs translation to {lang}:
```
{arb_missing_str}
```

"""},
    ]

for lang in TARGET_LANGS:
    print(f"{lang}: starting")
    if lang == REFERENCE_LANG:
        continue
    if "_" in lang:
        continue
    arb_lang_str = get_arb_lang_str(lang)
    arb_path = os.path.join(ARB_DIR, f"app_{lang}.arb")
    arb_lang_dict = json.loads(arb_lang_str)
    expected_keys = get_missing_keys(arb_en_dict, arb_lang_dict)
    if not expected_keys:
        continue
    expected_dict = {k:arb_en_dict[k] for k in expected_keys}
    arb_missing_str = json.dumps(expected_dict, ensure_ascii=False, indent=2)

    rsp = client.chat.completions.create(
        model=MODEL,
        messages=get_prompt_messages(lang, arb_en_str, arb_lang_str, arb_missing_str),
        temperature=0,
        reasoning_effort="high",
    )
    content = rsp.choices[0].message.content
    try:
        new_translations = extract_json(content)
        print(f"{lang}: new_translations: {new_translations}")
    except Exception as e:
        print(e)

    cnt = 0
    for key in expected_keys:
        if key in new_translations:
            arb_lang_dict[key] = new_translations[key]
            cnt += 1
        else:
            print(f"{lang}: missing key: {key}")
    
    with open(arb_path, "w", encoding="utf-8") as f:
        json.dump(format_arb(arb_lang_dict), f, ensure_ascii=False, indent=2)

    print(f"{lang}: translated keys: {cnt}")

# %%

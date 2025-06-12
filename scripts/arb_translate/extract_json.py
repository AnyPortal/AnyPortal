import re
import json
from typing import Any


class JSONWithCommentsDecoder(json.JSONDecoder):
    def __init__(self, **kw):
        super().__init__(**kw)

    def decode(self, s: str) -> Any:
        s = '\n'.join(l if not l.lstrip().startswith('//') else '' for l in s.split('\n')) # allow //
        s = re.sub(r',\s*([\]}])', r'\1', s) # allow trailing comma
        return super().decode(s)

def extract_json(text) -> dict:
    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL).strip()
    match = re.search(r"({[\s\S]*})", cleaned)

    if match:
        json_str = match.group(1).strip()
        try:
            return json.loads(json_str, cls=JSONWithCommentsDecoder)
        except json.JSONDecodeError:
            return {}

    raise ValueError("No valid JSON block found in the input.")

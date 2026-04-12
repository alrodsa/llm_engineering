import json
from dataclasses import asdict
from pathlib import Path

from app.domain.entities.profile import Profile


class JsonExporter:

    def export(self, profiles: list[Profile], path: str) -> None:
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        data = [asdict(p) for p in profiles]
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

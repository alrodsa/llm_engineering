# Synthetic Profile Generator

Generate synthetic user profiles using LLMs (Hugging Face), store them in SQLite, interact through a Gradio UI, and export datasets to JSON.

## Quick Start

```bash
pip install -e .
python main.py
```

The Gradio interface will open in your browser, where you can:

1. **Generate** — Select the number of profiles and click Generate
2. **View** — See generated profiles in the JSON viewer
3. **Export** — Download the full dataset as a JSON file

## Architecture

This project follows **Clean Architecture**:

- **Domain** — Entities and repository/service interfaces
- **Application** — Use cases that orchestrate business logic
- **Infrastructure** — LLM integration, SQLite persistence, JSON export
- **Presentation** — Gradio web interface

## Project Structure

```
synthetic-profile-generator/
├── app/
│   ├── application/       # Use cases and DTOs
│   ├── domain/            # Entities, repository and service interfaces
│   ├── infrastructure/    # LLM, DB, exporters, validation
│   ├── presentation/      # Gradio UI
│   └── config/            # Settings
├── data/                  # Database and exports
├── main.py
└── pyproject.toml
```

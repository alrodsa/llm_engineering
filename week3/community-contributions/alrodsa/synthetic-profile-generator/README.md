# Synthetic Profile Generator

Generate synthetic user profiles using LLMs (Hugging Face), store them in SQLite, interact through a Gradio UI, and export datasets to JSON.

## What Has Been Implemented

This project implements a complete synthetic profile generator following Clean Architecture principles. Key features include:

- **Profile Generation**: Uses HuggingFace transformers to generate realistic user profiles with configurable parameters (model, max tokens, quantization).
- **Data Persistence**: Stores generated profiles in a SQLite database using SQLAlchemy.
- **Web Interface**: Gradio-based UI for easy interaction, allowing users to generate profiles, view them, and export datasets.
- **Export Functionality**: Export all profiles to JSON format for further analysis or use.
- **Validation**: Built-in profile validation to ensure data quality.
- **Use Cases**: Modular use cases for generating profiles, counting existing profiles, and exporting data.
- **Clean Architecture**: Organized into Domain (entities, repositories, services), Application (use cases, DTOs), Infrastructure (LLM, DB, exporters), and Presentation (Gradio UI) layers.

## Installation

### Using uv (Recommended)

If you have uv installed, you can install the project and its dependencies as follows:

```bash
uv pip install -e .
```

This will install the package in editable mode along with all required dependencies.

**Note**: If you're using a devcontainer, the installation is handled automatically.

### Alternative: Using pip

```bash
pip install -e .
```

## Launching the Application

After installation, you can launch the Gradio application in several ways:

### Option 1: Using the installed script

```bash
profile-generator
```

### Option 2: Running directly

```bash
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
├── src/
│   ├── application/       # Use cases and DTOs
│   ├── domain/            # Entities, repository and service interfaces
│   ├── infrastructure/    # LLM, DB, exporters, validation
│   ├── presentation/      # Gradio UI
│   └── config/            # Settings
├── data/                  # Database and exports
├── main.py
└── pyproject.toml
```

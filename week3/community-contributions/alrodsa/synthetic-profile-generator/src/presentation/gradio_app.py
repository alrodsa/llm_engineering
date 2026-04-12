import gradio as gr

from app.application.use_cases.generate_profiles import GenerateProfilesUseCase
from app.application.use_cases.export_profiles_to_json import ExportProfilesToJsonUseCase
from app.application.use_cases.count_profiles import CountProfilesUseCase


class GradioApp:

    def __init__(
        self,
        generate_use_case: GenerateProfilesUseCase,
        export_use_case: ExportProfilesToJsonUseCase,
        count_use_case: CountProfilesUseCase,
        export_path: str,
    ):
        self._generate_use_case = generate_use_case
        self._export_use_case = export_use_case
        self._count_use_case = count_use_case
        self._export_path = export_path

    def _generate(self, num_profiles: int) -> tuple[dict, str]:
        result = self._generate_use_case.execute(int(num_profiles))
        total = self._count_use_case.execute()
        return result, f"Total profiles in database: {total}"

    def _export(self) -> tuple[str | None, str]:
        path = self._export_use_case.execute(self._export_path)
        if not path:
            return None, "No profiles to export."
        return path, f"Exported to {path}"

    def _count(self) -> str:
        total = self._count_use_case.execute()
        return f"Total profiles in database: {total}"

    def build(self) -> gr.Blocks:
        with gr.Blocks(title="Synthetic Profile Generator") as app:
            gr.Markdown("# Synthetic Profile Generator")
            gr.Markdown("Generate synthetic user profiles using LLMs, store in SQLite, and export to JSON.")

            with gr.Row():
                num_slider = gr.Slider(
                    minimum=1,
                    maximum=50,
                    value=5,
                    step=1,
                    label="Number of profiles to generate",
                )

            with gr.Row():
                generate_btn = gr.Button("Generate Profiles", variant="primary")
                export_btn = gr.Button("Export to JSON")
                count_btn = gr.Button("Refresh Count")

            status_text = gr.Textbox(label="Status", interactive=False)
            output_json = gr.JSON(label="Generated Profiles")
            export_file = gr.File(label="Download Export")

            generate_btn.click(
                fn=self._generate,
                inputs=[num_slider],
                outputs=[output_json, status_text],
            )

            export_btn.click(
                fn=self._export,
                inputs=[],
                outputs=[export_file, status_text],
            )

            count_btn.click(
                fn=self._count,
                inputs=[],
                outputs=[status_text],
            )

        return app

# Dispatch API Documentation
The Dispatch API allows users to interact with an approximation of Australia's National Electricity Market Dispatch Engine (NEMDE). See [https://akxen.github.io/dispatch-api-docs](https://akxen.github.io/dispatch-api-docs) for tutorials and case studies outlining the API's operation.

## Repository layout

| Path | Contents |
| :--- | :------- |
| `docs/` | Site source: markdown pages and the notebooks rendered as pages |
| `docs/tutorials/` | Tutorial notebooks |
| `docs/case-studies/` | Case study notebooks (code cells tagged `hide-input` are hidden on the site) |
| `docs/model-validation/` | Model validation notebooks (code hidden as above) |
| `data/` | Sample NEMDE case file used by the tutorials |
| `mkdocs.yml` | Site configuration and navigation |

Notebooks are rendered by [mkdocs-jupyter](https://github.com/danielfrg/mkdocs-jupyter) from their saved outputs; the build doesn't run them. To update a page, re-run its notebook in Jupyter and commit it with its outputs. Folders the notebooks write to (`data/`, `output/`, `results/`, `tmp/`, `config/`) are excluded from the site.

## Building the site

```
uv sync
uv run mkdocs serve        # preview at http://127.0.0.1:8000/dispatch-api-docs/
uv run jupyter lab         # edit and run the notebooks
```

Pushes to `main` build the site and deploy it to the `gh-pages` branch (`.github/workflows/docs.yml`).

jupyter nbconvert --to markdown --output-dir ./docs/tutorials ../tutorials/notebooks/running-a-model/running-a-model.ipynb
jupyter nbconvert --to markdown --output-dir ./docs/tutorials ../tutorials/notebooks/modifying-a-case-file/modifying-a-case-file.ipynb
jupyter nbconvert --to markdown --output-dir ./docs/tutorials ../tutorials/notebooks/scenario-analysis-line-plot/scenario-analysis-line-plot.ipynb
jupyter nbconvert --to markdown --output-dir ./docs/tutorials ../tutorials/notebooks/scenario-analysis-heatmap/scenario-analysis-heatmap.ipynb
jupyter nbconvert --to markdown --output-dir ./docs/tutorials ../tutorials/notebooks/converting-a-case-file/converting-a-case-file.ipynb
jupyter nbconvert --to markdown --TemplateExporter.exclude_input=True --output-dir ./docs/model-validation/202011 ../model-validation/202011/model-validation.ipynb
jupyter nbconvert --to markdown --TemplateExporter.exclude_input=True --output-dir ./docs/model-validation/202104 ../model-validation/202104/model-validation.ipynb
jupyter nbconvert --to markdown --TemplateExporter.exclude_input=True --output-dir ./docs/case-studies/price-volatility ../case-studies/price-volatility/price-volatility.ipynb
cp ../case-studies/price-volatility/supply-curve.gif ./docs/case-studies/price-volatility/supply-curve.gif 
cp ../case-studies/price-volatility/output/heatmap-no-title.png ./docs/case-studies/price-volatility/heatmap-no-title.png
jupyter nbconvert --to markdown --TemplateExporter.exclude_input=True --output-dir ./docs/case-studies/rebid-analysis ../case-studies/rebid-analysis/rebid-analysis.ipynb

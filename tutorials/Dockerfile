# Choose your desired base image
FROM jupyter/minimal-notebook:latest

# Name your environment and choose python 3.9 version
ARG conda_env=python39
ARG py_ver=3.9

COPY --chown=${NB_UID}:${NB_GID} environment.yml /home/$NB_USER/tmp/
RUN cd /home/$NB_USER/tmp/ && \
    conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
    conda clean --all -f -y

# Create Python 3.9 environment and link it to Jupyter
RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Prepend conda environment to path
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# Set as default environment
ENV CONDA_DEFAULT_ENV ${conda_env}

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root"]

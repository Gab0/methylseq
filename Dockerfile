FROM nfcore/base:1.9
LABEL authors="Phil Ewels" \
      description="Docker image containing all software requirements for the nf-core/methylseq pipeline"

# Install the conda environment
RUN conda update conda
COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

COPY bin/* /opt/conda/envs/nf-core-methylseq-1.6dev/bin
# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH=/opt/conda/envs/nf-core-methylseq-1.6dev/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-core-methylseq-1.6dev > nf-core-methylseq-1.6dev.yml

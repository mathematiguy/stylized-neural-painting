FROM mathematiguy/stylized-neural-painting

RUN apt update && apt install -y curl git

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install node.js
RUN apt update && \
  curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN apt install -y nodejs

# Install jupyter-server-proxy
RUN  pip3 install jupyter-server-proxy
# Install jupyter-vscode-proxy
RUN pip3 install jupyter-vscode-proxy
# Install server-proxy extension
RUN jupyter labextension install @jupyterlab/server-proxy

# Add jovyan home
RUN mkdir /home/jovyan
ENV NB_PREFIX /

# Run the notebook
CMD ["sh","-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]


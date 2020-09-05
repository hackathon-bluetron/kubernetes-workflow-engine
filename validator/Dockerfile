FROM ubuntu:16.04

LABEL maintainer="Pravat Bhusan Parida" 

workdir /

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl \
    && apt-get install -y python3 \
    && curl -o /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" \
    && python3 /tmp/get-pip.py \
    && pip install openpyxl \
    && pip install argparse \
    && pip install numpy \
    && apt autoremove -y 

COPY workboook_validator.py .

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["tail", "-f", "/dev/null"]

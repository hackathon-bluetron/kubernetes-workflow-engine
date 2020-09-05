FROM ubuntu:16.04

workdir /

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y curl \
    && apt-get install -y python3 \
    && curl -o /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" \
    && python3 /tmp/get-pip.py \
    && pip install pandas \
    && pip install argparse \
#    && pip install glob \
    && apt autoremove -y

COPY data_merger.py .

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["tail", "-f", "/dev/null"]
